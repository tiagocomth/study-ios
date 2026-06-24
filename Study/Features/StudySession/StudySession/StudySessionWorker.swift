//
//  StudySessionWorker.swift
//  Study
//

import Foundation

final class StudySessionWorker: StudySessionWorkerProtocol {
    private let categoryService: CategoryServiceProtocol
    private let categoryLocalStore: CategoryLocalStoreServiceProtocol
    private let studySessionTracker: StudySessionTrackerServiceProtocol
    private let offlineOperationQueue: OfflineOperationQueueServiceProtocol
    private let studySessionActionSender: StudySessionActionSenderServiceProtocol
    private let currentUserId: @Sendable () -> UUID?
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date
    private var tasks: [Task<Void, Never>] = []
    
    init(
        categoryService: CategoryServiceProtocol,
        categoryLocalStore: CategoryLocalStoreServiceProtocol,
        studySessionTracker: StudySessionTrackerServiceProtocol,
        offlineOperationQueue: OfflineOperationQueueServiceProtocol,
        studySessionActionSender: StudySessionActionSenderServiceProtocol,
        currentUserId: @escaping @Sendable () -> UUID?,
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.categoryService = categoryService
        self.categoryLocalStore = categoryLocalStore
        self.studySessionTracker = studySessionTracker
        self.offlineOperationQueue = offlineOperationQueue
        self.studySessionActionSender = studySessionActionSender
        self.currentUserId = currentUserId
        self.makeId = makeId
        self.now = now
    }

    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory] {
        let localCategories = try categoryLocalStore.getAll()
        
        let task = Task { @MainActor [weak self] in
            guard let self else { return }
            guard let backendCategories = try? await refreshCategoriesFromBackend() else { return }
            onBackendRefresh(backendCategories)
        }
        
        tasks.append(task)
        return localCategories
    }

    private func refreshCategoriesFromBackend() async throws -> [StudyCategory] {
        let backendCategories = try await categoryService.getAll()
        try categoryLocalStore.saveAll(backendCategories)
        return backendCategories
    }

    func createCategory(
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        guard let userId = currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let localCategory = StudyCategory(
            categoryId: makeId(),
            userId: userId,
            name: dto.name,
            createdAt: ISO8601DateFormatter().string(from: now())
        )

        try categoryLocalStore.save(localCategory)

        let task = Task { @MainActor [weak self] in
            guard let self else { return }
            await sendCreateCategory(
                id: localCategory.categoryId,
                dto,
                onShouldRollback: onShouldRollback
            )
        }

        tasks.append(task)
        return localCategory
    }

    func updateCategory(
        id: UUID,
        dto: UpdateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        guard let previousCategory = try categoryLocalStore.getById(id) else {
            throw StudySessionWorkerError.categoryNotFound
        }

        let localCategory = StudyCategory(
            categoryId: previousCategory.categoryId,
            userId: previousCategory.userId,
            name: dto.name,
            createdAt: previousCategory.createdAt
        )

        try categoryLocalStore.save(localCategory)

        let task = Task { @MainActor [weak self] in
            guard let self else { return }
            await sendUpdateCategory(
                id: id,
                dto: dto,
                previousCategory: previousCategory,
                onShouldRollback: onShouldRollback
            )
        }

        tasks.append(task)
        return localCategory
    }

    func deleteCategory(
        id: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) throws {
        guard let deletedCategory = try categoryLocalStore.getById(id) else {
            throw StudySessionWorkerError.categoryNotFound
        }

        try categoryLocalStore.delete(id: id)

        let task = Task { @MainActor [weak self] in
            guard let self else { return }
            await sendDeleteCategory(
                id: id,
                deletedCategory: deletedCategory,
                onShouldRollback: onShouldRollback
            )
        }

        tasks.append(task)
    }

    func getActiveStudySession() async -> LocalStudySession? {
        await studySessionTracker.getActiveSession()
    }

    func startStudySession(categoryId: UUID) async throws {
        let action = try await studySessionTracker.start(categoryId: categoryId)
        sendStudySessionAction(action)
    }

    func pauseStudySession() async throws {
        let action = try await studySessionTracker.pause()
        sendStudySessionAction(action)
    }

    func resumeStudySession() async throws {
        let action = try await studySessionTracker.resume()
        sendStudySessionAction(action)
    }

    func finishStudySession() async throws {
        let action = try await studySessionTracker.finish()
        sendStudySessionAction(action)
    }
    
    deinit {
        for task in tasks {
            task.cancel()
        }
    }
}

private extension StudySessionWorker {

    func sendCreateCategory(
        id: UUID,
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryService.create(dto)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.createCategory(dto))
                    return
                }

                try categoryLocalStore.rollbackCreate(id: id)
                onShouldRollback(error)
            } catch {}
        }
    }

    func sendUpdateCategory(
        id: UUID,
        dto: UpdateCategoryDTO,
        previousCategory: StudyCategory,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryService.update(id: id, dto: dto)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.updateCategory(id: id, dto: dto))
                    return
                }

                try categoryLocalStore.rollbackUpdate(previousCategory: previousCategory)
                onShouldRollback(error)
            } catch {}
        }
    }

    func sendDeleteCategory(
        id: UUID,
        deletedCategory: StudyCategory,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryService.delete(id: id)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.deleteCategory(id))
                    return
                }

                try categoryLocalStore.rollbackDelete(deletedCategory: deletedCategory)
                onShouldRollback(error)
            } catch {}
        }
    }

    func sendStudySessionAction(_ action: StudySessionTrackerAction) {
        let task = Task { [studySessionActionSender] in
            do {
                try await studySessionActionSender.send(action)
            } catch {}
        }

        tasks.append(task)
    }

    func enqueue(_ kind: PendingOfflineOperationKind) async throws {
        try await offlineOperationQueue.enqueue(makeOperation(kind))
    }

    func makeOperation(_ kind: PendingOfflineOperationKind) -> PendingOfflineOperation {
        PendingOfflineOperation(
            id: makeId(),
            createdAt: now(),
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: kind
        )
    }
}

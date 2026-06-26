//
//  CategoryOrchestration.swift
//  Study
//

import Foundation

@MainActor
final class CategoryOrchestration: CategoryOrchestrationProtocol {
    private let categoryRemote: CategoryRemoteProtocol
    private let categoryLocal: CategoryStoreLocalProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let currentUserId: () -> UUID?
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date
    
    init(
        categoryRemote: CategoryRemoteProtocol,
        categoryLocal: CategoryStoreLocalProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        currentUserId: @escaping () -> UUID?,
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.categoryRemote = categoryRemote
        self.categoryLocal = categoryLocal
        self.offlineOperationQueue = offlineOperationQueue
        self.currentUserId = currentUserId
        self.makeId = makeId
        self.now = now
    }
    
    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory] {
        guard let userId = currentUserId() else {
            throw CategoryOrchestrationError.missingCurrentUser
        }

        let localCategories = try categoryLocal.getAll(userId: userId)
        
        Task { @MainActor [weak self] in
            
            guard let self else { return }

            guard let backendCategories = try? await refreshCategories(userId: userId) else { return }
            onBackendRefresh(backendCategories)
        }
        
        return localCategories
    }
    
    func create(
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        guard let userId = currentUserId() else {
            throw CategoryOrchestrationError.missingCurrentUser
        }
        
        let localCategory = StudyCategory(
            categoryId: makeId(),
            userId: userId,
            name: dto.name,
            createdAt: ISO8601DateFormatter().string(from: now())
        )
        
        try categoryLocal.save(localCategory)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            await processCreateInBackground(
                dto,
                userId: userId,
                categoryId: localCategory.categoryId,
                onShouldRollback: onShouldRollback
            )
        }
        
        return localCategory
    }
    
    func update(
        id: UUID,
        dto: UpdateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        guard let userId = currentUserId() else {
            throw CategoryOrchestrationError.missingCurrentUser
        }

        guard let previousCategory = try categoryLocal.getById(id, userId: userId) else {
            throw CategoryOrchestrationError.categoryNotFound
        }
        
        let localCategory = StudyCategory(
            categoryId: previousCategory.categoryId,
            userId: previousCategory.userId,
            name: dto.name,
            createdAt: previousCategory.createdAt
        )
        
        try categoryLocal.save(localCategory)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            await processUpdateInBackground(
                id: id,
                dto: dto,
                userId: userId,
                previousCategory: previousCategory,
                onShouldRollback: onShouldRollback
            )
        }
        
        return localCategory
    }
    
    func delete(
        id: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) throws {
        guard let userId = currentUserId() else {
            throw CategoryOrchestrationError.missingCurrentUser
        }

        guard let deletedCategory = try categoryLocal.getById(id, userId: userId) else {
            throw CategoryOrchestrationError.categoryNotFound
        }
        
        try categoryLocal.delete(id: id, userId: userId)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            await processDeleteInBackground(
                id: id,
                userId: userId,
                deletedCategory: deletedCategory,
                onShouldRollback: onShouldRollback
            )
        }
    }
}

private extension CategoryOrchestration {
    
    func hasPendingOperations(userId: UUID) async -> Bool {
        await offlineOperationQueue.ensureRestored(userId: userId)
        return await offlineOperationQueue.peek(userId: userId) != nil
    }

    private func refreshCategories(userId: UUID) async throws -> [StudyCategory]? {
        await categoryLocal.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return nil }

        let backendCategories = try await categoryRemote.getAll()
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return nil }

        try categoryLocal.saveAll(backendCategories)
        return backendCategories
    }

    func processCreateInBackground(
        _ dto: CreateCategoryDTO,
        userId: UUID,
        categoryId: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        if await hasPendingOperations(userId: userId) {
            try? await enqueue(.createCategory(dto), userId: userId)
            return
        }

        await sendCreateCategory(
            userId: userId,
            id: categoryId,
            dto,
            onShouldRollback: onShouldRollback
        )
    }

    func processUpdateInBackground(
        id: UUID,
        dto: UpdateCategoryDTO,
        userId: UUID,
        previousCategory: StudyCategory,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        if await hasPendingOperations(userId: userId) {
            try? await enqueue(.updateCategory(id: id, dto: dto), userId: userId)
            return
        }

        await sendUpdateCategory(
            userId: userId,
            id: id,
            dto: dto,
            previousCategory: previousCategory,
            onShouldRollback: onShouldRollback
        )
    }

    func processDeleteInBackground(
        id: UUID,
        userId: UUID,
        deletedCategory: StudyCategory,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        if await hasPendingOperations(userId: userId) {
            try? await enqueue(.deleteCategory(id), userId: userId)
            return
        }

        await sendDeleteCategory(
            userId: userId,
            id: id,
            deletedCategory: deletedCategory,
            onShouldRollback: onShouldRollback
        )
    }
    
    private func sendCreateCategory(
        userId: UUID,
        id: UUID,
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryRemote.create(dto)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.createCategory(dto), userId: userId)
                    return
                }
                
                try categoryLocal.rollbackCreate(id: id, userId: userId)
                onShouldRollback(error)
            } catch {}
        }
    }
    
    private func sendUpdateCategory(
        userId: UUID,
        id: UUID,
        dto: UpdateCategoryDTO,
        previousCategory: StudyCategory,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryRemote.update(id: id, dto: dto)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.updateCategory(id: id, dto: dto), userId: userId)
                    return
                }
                
                try categoryLocal.rollbackUpdate(previousCategory: previousCategory)
                onShouldRollback(error)
            } catch {}
        }
    }
    
    private func sendDeleteCategory(
        userId: UUID,
        id: UUID,
        deletedCategory: StudyCategory,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryRemote.delete(id: id)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.deleteCategory(id), userId: userId)
                    return
                }
                
                try categoryLocal.rollbackDelete(deletedCategory: deletedCategory)
                onShouldRollback(error)
            } catch {}
        }
    }
    
    private func enqueue(_ kind: PendingOfflineOperationKind, userId: UUID) async throws {
        await offlineOperationQueue.ensureRestored(userId: userId)
        try await offlineOperationQueue.enqueue(makeOperation(kind), userId: userId)
    }
    
    private func makeOperation(_ kind: PendingOfflineOperationKind) -> PendingOfflineOperation {
        PendingOfflineOperation(
            id: makeId(),
            createdAt: now(),
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: kind
        )
    }
}

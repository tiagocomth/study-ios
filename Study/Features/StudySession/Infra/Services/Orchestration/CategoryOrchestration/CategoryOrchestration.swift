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
    private let currentUserId: @Sendable () -> UUID?
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date
    private var tasks: [Task<Void, Never>] = []
    
    init(
        categoryRemote: CategoryRemoteProtocol,
        categoryLocal: CategoryStoreLocalProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        currentUserId: @escaping @Sendable () -> UUID?,
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
        let localCategories = try categoryLocal.getAll()
        
        let task = Task { @MainActor [weak self] in
            
            guard let self else { return }
            
            guard let backendCategories = try? await refreshCategoriesFromBackendIfQueueIsEmpty() else { return }
            onBackendRefresh(backendCategories)
        }
        
        tasks.append(task)
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
    
    func update(
        id: UUID,
        dto: UpdateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        guard let previousCategory = try categoryLocal.getById(id) else {
            throw CategoryOrchestrationError.categoryNotFound
        }
        
        let localCategory = StudyCategory(
            categoryId: previousCategory.categoryId,
            userId: previousCategory.userId,
            name: dto.name,
            createdAt: previousCategory.createdAt
        )
        
        try categoryLocal.save(localCategory)
        
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
    
    func delete(
        id: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) throws {
        guard let deletedCategory = try categoryLocal.getById(id) else {
            throw CategoryOrchestrationError.categoryNotFound
        }
        
        try categoryLocal.delete(id: id)
        
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
    
    deinit {
        for task in tasks {
            task.cancel()
        }
    }
}

private extension CategoryOrchestration {
    private func refreshCategoriesFromBackendIfQueueIsEmpty() async throws -> [StudyCategory]? {
        guard await offlineOperationQueue.peek() == nil else { return nil }

        let backendCategories = try await categoryRemote.getAll()
        guard await offlineOperationQueue.peek() == nil else { return nil }

        try categoryLocal.saveAll(backendCategories)
        return backendCategories
    }
    
    private func sendCreateCategory(
        id: UUID,
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryRemote.create(dto)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.createCategory(dto))
                    return
                }
                
                try categoryLocal.rollbackCreate(id: id)
                onShouldRollback(error)
            } catch {}
        }
    }
    
    private func sendUpdateCategory(
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
                    try await enqueue(.updateCategory(id: id, dto: dto))
                    return
                }
                
                try categoryLocal.rollbackUpdate(previousCategory: previousCategory)
                onShouldRollback(error)
            } catch {}
        }
    }
    
    private func sendDeleteCategory(
        id: UUID,
        deletedCategory: StudyCategory,
        onShouldRollback: @escaping ShouldRollback
    ) async {
        do {
            try await categoryRemote.delete(id: id)
        } catch {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(.deleteCategory(id))
                    return
                }
                
                try categoryLocal.rollbackDelete(deletedCategory: deletedCategory)
                onShouldRollback(error)
            } catch {}
        }
    }
    
    private func enqueue(_ kind: PendingOfflineOperationKind) async throws {
        try await offlineOperationQueue.enqueue(makeOperation(kind))
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

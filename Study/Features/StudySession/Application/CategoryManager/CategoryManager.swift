//
//  CategoryManager.swift
//  Study
//

import Foundation

@MainActor
final class CategoryManager: CategoryManagerProtocol {
    private let categoryAPI: CategoryAPIProtocol
    private let categoryLocal: CategoryStoreLocalProtocol
    private let operationManager: OperationManagerProtocol
    private let currentUserId: () -> UUID?
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date
    
    init(
        categoryAPI: CategoryAPIProtocol,
        categoryLocal: CategoryStoreLocalProtocol,
        operationManager: OperationManagerProtocol,
        currentUserId: @escaping () -> UUID?,
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.categoryAPI = categoryAPI
        self.categoryLocal = categoryLocal
        self.operationManager = operationManager
        self.currentUserId = currentUserId
        self.makeId = makeId
        self.now = now
    }

    func categoryChanges() -> AsyncStream<[StudyCategory]> {
        guard let userId = currentUserId() else {
            return AsyncStream { continuation in
                continuation.yield([])
                continuation.finish()
            }
        }

        return categoryLocal.categoryChanges(userId: userId)
    }
    
    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory] {
        guard let userId = currentUserId() else {
            throw CategoryManagerError.missingCurrentUser
        }

        let localCategories = try categoryLocal.getAll(userId: userId)
        
        Task { @MainActor [weak self] in
            guard let self else { return }

            guard let backendCategories = try? await refreshCategories(userId: userId) else { return }
            onBackendRefresh(backendCategories)
        }
        
        return localCategories
    }
    
    func create(_ dto: CreateCategoryDTO) throws -> StudyCategory {
        guard let userId = currentUserId() else {
            throw CategoryManagerError.missingCurrentUser
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
                categoryId: localCategory.categoryId
            )
        }
        
        return localCategory
    }
    
    func update(id: UUID, dto: UpdateCategoryDTO) throws -> StudyCategory {
        guard let userId = currentUserId() else {
            throw CategoryManagerError.missingCurrentUser
        }

        guard let previousCategory = try categoryLocal.getById(id, userId: userId) else {
            throw CategoryManagerError.categoryNotFound
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
            )
        }
        
        return localCategory
    }
    
    func delete(id: UUID) throws {
        guard let userId = currentUserId() else {
            throw CategoryManagerError.missingCurrentUser
        }

        guard let deletedCategory = try categoryLocal.getById(id, userId: userId) else {
            throw CategoryManagerError.categoryNotFound
        }
        
        try categoryLocal.delete(id: id, userId: userId)
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            await processDeleteInBackground(
                id: id,
                userId: userId,
                deletedCategory: deletedCategory
            )
        }
    }
}

private extension CategoryManager {
    private func refreshCategories(userId: UUID) async throws -> [StudyCategory]? {
        await categoryLocal.ensureRestored(userId: userId)

        let hasPendingBeforeFetch = await operationManager.hasPendingOperations(userId: userId)
        guard !hasPendingBeforeFetch else { return nil }

        let backendCategories = try await categoryAPI.getAll()

        let hasPendingAfterFetch = await operationManager.hasPendingOperations(userId: userId)
        guard !hasPendingAfterFetch else { return nil }

        try categoryLocal.saveAll(backendCategories)
        return backendCategories
    }

    func processCreateInBackground(
        _ dto: CreateCategoryDTO,
        userId: UUID,
        categoryId: UUID
    ) async {
        let result = await operationManager.dispatch(.createCategory(dto), userId: userId) { () throws(NetworkError) -> Void in
            try await categoryAPI.create(dto)
        }

        await handleDispatchResult(
            result,
            rollback: { try categoryLocal.rollbackCreate(id: categoryId, userId: userId) }
        )
    }

    func processUpdateInBackground(
        id: UUID,
        dto: UpdateCategoryDTO,
        userId: UUID,
        previousCategory: StudyCategory
    ) async {
        let result = await operationManager.dispatch(.updateCategory(id: id, dto: dto), userId: userId) { () throws(NetworkError) -> Void in
            try await categoryAPI.update(id: id, dto: dto)
        }

        await handleDispatchResult(
            result,
            rollback: { try categoryLocal.rollbackUpdate(previousCategory: previousCategory) }
        )
    }

    func processDeleteInBackground(
        id: UUID,
        userId: UUID,
        deletedCategory: StudyCategory
    ) async {
        let result = await operationManager.dispatch(.deleteCategory(id), userId: userId) { () throws(NetworkError) -> Void in
            try await categoryAPI.delete(id: id)
        }

        await handleDispatchResult(
            result,
            rollback: { try categoryLocal.rollbackDelete(deletedCategory: deletedCategory) }
        )
    }

    func handleDispatchResult(
        _ result: OperationDispatchResult,
        rollback: () throws -> Void
    ) async {
        guard case .failed = result else { return }

        try? rollback()
    }
}

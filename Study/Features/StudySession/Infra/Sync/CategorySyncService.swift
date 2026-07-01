//
//  CategorySyncService.swift
//  Study
//

import Foundation

@MainActor
final class CategorySyncService: CategorySyncServiceProtocol {
    private let categoryAPI: CategoryAPIProtocol
    private let categoryLocal: CategoryStoreLocalProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol

    init(
        categoryAPI: CategoryAPIProtocol,
        categoryLocal: CategoryStoreLocalProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol
    ) {
        self.categoryAPI = categoryAPI
        self.categoryLocal = categoryLocal
        self.offlineOperationQueue = offlineOperationQueue
    }

    func refreshFromBackendIfQueueIsEmpty(userId: UUID) async throws {
        await categoryLocal.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }

        let backendCategories = try await categoryAPI.getAll()
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }

        try categoryLocal.saveAll(backendCategories)
    }
}

//
//  CategorySyncService.swift
//  Study
//

import Foundation

@MainActor
final class CategorySyncService: CategorySyncServiceProtocol {
    private let categoryRemote: CategoryRemoteProtocol
    private let categoryLocal: CategoryStoreLocalProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol

    init(
        categoryRemote: CategoryRemoteProtocol,
        categoryLocal: CategoryStoreLocalProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol
    ) {
        self.categoryRemote = categoryRemote
        self.categoryLocal = categoryLocal
        self.offlineOperationQueue = offlineOperationQueue
    }

    func refreshFromBackendIfQueueIsEmpty(userId: UUID) async throws {
        await categoryLocal.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }

        let backendCategories = try await categoryRemote.getAll()
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }

        try categoryLocal.saveAll(backendCategories)
    }
}

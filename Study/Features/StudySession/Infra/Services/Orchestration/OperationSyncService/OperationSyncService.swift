//
//  StudySessionSyncService.swift
//  Study
//

import Foundation

@MainActor
final class OperationSyncService: OperationSyncServiceProtocol {
    private let offlineOperationSender: OfflineOperationSenderRemoteProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let categoryRemote: CategoryRemoteProtocol
    private let categoryLocal: CategoryStoreLocalProtocol
    private var hasRestored: Bool
    private var isSyncing: Bool

    init(
        offlineOperationSender: OfflineOperationSenderRemoteProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        categoryRemote: CategoryRemoteProtocol,
        categoryLocal: CategoryStoreLocalProtocol
    ) {
        self.offlineOperationSender = offlineOperationSender
        self.offlineOperationQueue = offlineOperationQueue
        self.categoryRemote = categoryRemote
        self.categoryLocal = categoryLocal
        self.hasRestored = false
        self.isSyncing = false
    }
    
    func sync() async throws {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        await restore()

        guard try await flushPendingOperations() else { return }
        try await refreshCategories()
    }
}

private extension OperationSyncService {
    func restore() async {
        guard !hasRestored else { return }
        await offlineOperationQueue.restore()
        hasRestored = true
    }

    func flushPendingOperations() async throws -> Bool {
        for operation in await offlineOperationQueue.allPending() {
            do {
                try await offlineOperationSender.send(operation)
                try await offlineOperationQueue.markFirstSucceeded(operation.id)
                
            } catch is NetworkError {
                try? await offlineOperationQueue.markFirstFailed(operation.id)
                return false
                
            } catch let error as OfflineOperationQueueLocalError {
                throw error
            } catch {
                throw error
            }
        }

        return true
    }

    func refreshCategories() async throws {
        guard await offlineOperationQueue.peek() == nil else { return }

        let backendCategories = try await categoryRemote.getAll()
        guard await offlineOperationQueue.peek() == nil else { return }

        try categoryLocal.saveAll(backendCategories)
    }
}

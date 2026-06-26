//
//  StudySessionSyncService.swift
//  Study
//

import Foundation

@MainActor
final class OperationSyncService: OperationSyncServiceProtocol {
    private let offlineOperationSender: OfflineOperationSenderRemoteProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let currentUserId: () -> UUID?
    private var isSyncing: Bool

    init(
        offlineOperationSender: OfflineOperationSenderRemoteProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        currentUserId: @escaping () -> UUID?
    ) {
        self.offlineOperationSender = offlineOperationSender
        self.offlineOperationQueue = offlineOperationQueue
        self.currentUserId = currentUserId
        self.isSyncing = false
    }
    
    func sync() async throws {
        guard let userId = currentUserId() else { return }
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }

        await offlineOperationQueue.ensureRestored(userId: userId)

        guard try await flushPendingOperations(userId: userId) else { return }
        //TODO: notifier worker ser um published, que o view model do study session conhece
    }
}

private extension OperationSyncService {
    private func flushPendingOperations(userId: UUID) async throws -> Bool {
        for operation in await offlineOperationQueue.allPending(userId: userId) {
            do {
                try await offlineOperationSender.send(operation)
                try await offlineOperationQueue.markFirstSucceeded(operation.id, userId: userId)
                
            } catch is NetworkError {
                try? await offlineOperationQueue.markFirstFailed(operation.id, userId: userId)
                return false
                
            } catch let error as OfflineOperationQueueLocalError {
                throw error
            } catch {
                throw error
            }
        }

        return true
    }
}

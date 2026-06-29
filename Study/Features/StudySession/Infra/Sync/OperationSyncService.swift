//
//  StudySessionSyncService.swift
//  Study
//

import Foundation

@MainActor
final class OperationSyncService: OperationSyncServiceProtocol {
    private let offlineOperationSender: OfflineOperationSenderProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let currentUserId: () -> UUID?
    private let logger: DomainLogging
    private var isSyncing: Bool

    init(
        offlineOperationSender: OfflineOperationSenderProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        currentUserId: @escaping () -> UUID?,
        logger: DomainLogging = OfflineOperationQueueLogger()
    ) {
        self.offlineOperationSender = offlineOperationSender
        self.offlineOperationQueue = offlineOperationQueue
        self.currentUserId = currentUserId
        self.logger = logger
        self.isSyncing = false
    }
    
    func sync() async throws -> OperationSyncResult {
        guard let userId = currentUserId() else { return .stoppedOnFailure }
        guard !isSyncing else { return .alreadyRunning }
        isSyncing = true
        defer { isSyncing = false }

        await offlineOperationQueue.ensureRestored(userId: userId)

        guard try await flushPendingOperations(userId: userId) else { return .stoppedOnFailure }
        return .completed
    }
}

private extension OperationSyncService {
    private func flushPendingOperations(userId: UUID) async throws -> Bool {
        while let operation = await offlineOperationQueue.peek(userId: userId) {
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

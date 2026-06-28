//
//  OfflineOperationQueueLocalProtocol.swift
//  Study
//

import Foundation

nonisolated protocol OfflineOperationQueueLocalProtocol {
    func restoreState(for userId: UUID) async -> RestoreState
    func ensureRestored(userId: UUID) async
    func enqueue(_ operation: PendingOfflineOperation, userId: UUID) async throws(OfflineOperationQueueLocalError)
    func peek(userId: UUID) async -> PendingOfflineOperation?
    func allPending(userId: UUID) async -> [PendingOfflineOperation]
    func markFirstSucceeded(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError)
    func markFirstFailed(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError)
    func removeOperation(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError)
    func clear(userId: UUID) async throws(OfflineOperationQueueLocalError)
}

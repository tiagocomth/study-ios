//
//  OfflineOperationQueueLocalProtocol.swift
//  Study
//

import Foundation

nonisolated protocol OfflineOperationQueueLocalProtocol {
    func restore() async
    func enqueue(_ operation: PendingOfflineOperation, userId: UUID) async throws(OfflineOperationQueueLocalError)
    func enqueue(_ operations: [PendingOfflineOperation], userId: UUID) async throws(OfflineOperationQueueLocalError)
    func peek(userId: UUID) async -> PendingOfflineOperation?
    func allPending(userId: UUID) async -> [PendingOfflineOperation]
    func markFirstSucceeded(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError)
    func markFirstFailed(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError)
    func clear(userId: UUID) async throws(OfflineOperationQueueLocalError)
}

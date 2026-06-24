//
//  OfflineOperationQueueServiceProtocol.swift
//  Study
//

import Foundation

nonisolated protocol OfflineOperationQueueServiceProtocol {
    func restore() async
    func enqueue(_ operation: PendingOfflineOperation) async throws(OfflineOperationQueueError)
    func enqueue(_ operations: [PendingOfflineOperation]) async throws(OfflineOperationQueueError)
    func peek() async -> PendingOfflineOperation?
    func allPending() async -> [PendingOfflineOperation]
    func markFirstSucceeded(_ id: UUID) async throws(OfflineOperationQueueError)
    func markFirstFailed(_ id: UUID) async throws(OfflineOperationQueueError)
}

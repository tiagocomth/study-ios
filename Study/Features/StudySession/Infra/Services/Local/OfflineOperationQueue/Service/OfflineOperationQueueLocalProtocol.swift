//
//  OfflineOperationQueueLocalProtocol.swift
//  Study
//

import Foundation

nonisolated protocol OfflineOperationQueueLocalProtocol {
    func restore() async
    func enqueue(_ operation: PendingOfflineOperation) async throws(OfflineOperationQueueLocalError)
    func enqueue(_ operations: [PendingOfflineOperation]) async throws(OfflineOperationQueueLocalError)
    func peek() async -> PendingOfflineOperation?
    func allPending() async -> [PendingOfflineOperation]
    func markFirstSucceeded(_ id: UUID) async throws(OfflineOperationQueueLocalError)
    func markFirstFailed(_ id: UUID) async throws(OfflineOperationQueueLocalError)
}

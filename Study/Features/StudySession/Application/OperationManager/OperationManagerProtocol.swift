//
//  OperationManagerProtocol.swift
//  Study
//

import Foundation

enum OperationDispatchResult: Sendable {
    case sent
    case enqueued
    case failed(NetworkError)
    case rollback
}

nonisolated protocol OperationManagerProtocol {
    func hasPendingOperations(userId: UUID) async -> Bool

    func dispatch(
        _ kind: PendingOfflineOperationKind,
        userId: UUID,
        sendRemote: () async throws(NetworkError) -> Void
    ) async -> OperationDispatchResult

    func enqueue(_ kind: PendingOfflineOperationKind, userId: UUID) async throws
}

//
//  OperationManager.swift
//  Study
//

import Foundation

final class OperationManager: OperationManagerProtocol {
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date

    init(
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.offlineOperationQueue = offlineOperationQueue
        self.makeId = makeId
        self.now = now
    }

    func hasPendingOperations(userId: UUID) async -> Bool {
        await offlineOperationQueue.ensureRestored(userId: userId)
        return await offlineOperationQueue.peek(userId: userId) != nil
    }

    func dispatch(
        _ kind: PendingOfflineOperationKind,
        userId: UUID,
        sendRemote: () async throws(NetworkError) -> Void
    ) async -> OperationDispatchResult {
        if await hasPendingOperations(userId: userId) {
            try? await enqueue(kind, userId: userId)
            return .enqueued
        }

        do {
            try await sendRemote()
            return .sent
        } catch let error {
            do {
                if OfflineRetryPolicy.shouldEnqueue(error) {
                    try await enqueue(kind, userId: userId)
                    return .enqueued
                } else {
                    return .failed(error)
                }
            } catch {
                return .rollback
            }
        }
    }

    func enqueue(_ kind: PendingOfflineOperationKind, userId: UUID) async throws {
        await offlineOperationQueue.ensureRestored(userId: userId)
        try await offlineOperationQueue.enqueue(makeOperation(kind), userId: userId)
    }
}

private extension OperationManager {
    nonisolated func makeOperation(_ kind: PendingOfflineOperationKind) -> PendingOfflineOperation {
        PendingOfflineOperation(
            id: makeId(),
            createdAt: now(),
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: kind
        )
    }
}

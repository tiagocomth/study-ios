//
//  OperationSyncServiceTests.swift
//  StudyTests
//

import Foundation
import Testing
@testable import Study

@MainActor
@Suite("OperationSyncService", .serialized)
struct OperationSyncServiceTests {
    @Test("removes a pending operation by id and persists the queue")
    func removesPendingOperation() async throws {
        let userId = UUID()
        let store = makeUserDefaults()
        let storageKey = "operation-sync-tests.\(UUID().uuidString)"
        let queue = makeQueue(userDefaults: store, key: storageKey)
        let firstOperation = makeOperation()
        let secondOperation = makeOperation()

        try await queue.enqueue(firstOperation, userId: userId)
        try await queue.enqueue(secondOperation, userId: userId)
        try await queue.removeOperation(firstOperation.id, userId: userId)

        let pendingOperations = await queue.allPending(userId: userId)
        #expect(pendingOperations == [secondOperation])

        let restoredQueue = makeQueue(userDefaults: store, key: storageKey)
        await restoredQueue.ensureRestored(userId: userId)
        let restoredPendingOperations = await restoredQueue.allPending(userId: userId)
        #expect(restoredPendingOperations == [secondOperation])
    }

    @Test("drops non-retryable failures and continues flushing the queue")
    func dropsNonRetryableFailuresDuringFlush() async throws {
        let userId = UUID()
        let queue = makeQueue(
            userDefaults: makeUserDefaults(),
            key: "operation-sync-tests.\(UUID().uuidString)"
        )
        let droppedOperation = makeOperation()
        let succeedingOperation = makeOperation()
        let sender = OfflineOperationSenderStub(resultsByOperationId: [
            droppedOperation.id: .failure(.notFound(message: "Session not found")),
            succeedingOperation.id: .success
        ])
        let service = OperationSyncService(
            offlineOperationSender: sender,
            offlineOperationQueue: queue,
            currentUserId: { userId },
            logger: NoOpLogger()
        )

        try await queue.enqueue(droppedOperation, userId: userId)
        try await queue.enqueue(succeedingOperation, userId: userId)
        let result = try await service.sync()
        let pendingOperations = await queue.allPending(userId: userId)

        #expect(result == .completed)
        #expect(pendingOperations.isEmpty)
        #expect(await sender.sentOperationIDs == [droppedOperation.id, succeedingOperation.id])
    }
}

private extension OperationSyncServiceTests {
    func makeQueue(userDefaults: UserDefaults, key: String) -> OfflineOperationQueueLocal {
        OfflineOperationQueueLocal(
            userDefaults: userDefaults,
            key: key,
            logger: NoOpLogger()
        )
    }

    func makeUserDefaults() -> UserDefaults {
        let suiteName = "operation-sync-tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    func makeOperation(id: UUID = UUID()) -> PendingOfflineOperation {
        PendingOfflineOperation(
            id: id,
            createdAt: Date(timeIntervalSince1970: 0),
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: .deleteCategory(UUID())
        )
    }
}

private struct NoOpLogger: DomainLogging {
    func debug(_ message: String) {}
    func info(_ message: String) {}
    func error(_ message: String) {}
}

private actor OfflineOperationSenderStub: OfflineOperationSenderProtocol {
    enum Result {
        case success
        case failure(NetworkError)
    }

    private let resultsByOperationId: [UUID: Result]
    private(set) var sentOperationIDs: [UUID] = []

    init(resultsByOperationId: [UUID: Result]) {
        self.resultsByOperationId = resultsByOperationId
    }

    func send(_ operation: PendingOfflineOperation) async throws(NetworkError) {
        sentOperationIDs.append(operation.id)

        switch resultsByOperationId[operation.id, default: .success] {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}

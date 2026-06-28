//
//  OfflineOperationQueueLocalTests.swift
//  StudyTests
//

import Testing
import Foundation
@testable import Study

@Suite("OfflineOperationQueueLocal", .serialized)
struct OfflineOperationQueueLocalTests {
    private let userA = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    private let userB = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    private let now = Date(timeIntervalSince1970: 1_719_324_800)

    @Test("restores pending operations isolated by user")
    func restoresScopedQueues() async throws {
        let userDefaults = makeUserDefaults()
        let queue = OfflineOperationQueueLocal(userDefaults: userDefaults, now: { now })
        let operationA = makeOperation(id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!, name: "Math")
        let operationB = makeOperation(id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!, name: "History")

        try await queue.enqueue(operationA, userId: userA)
        try await queue.enqueue(operationB, userId: userB)

        let restoredQueue = OfflineOperationQueueLocal(userDefaults: userDefaults, now: { now })
        await restoredQueue.ensureRestored(userId: userA)
        await restoredQueue.ensureRestored(userId: userB)

        #expect(await restoredQueue.allPending(userId: userA) == [operationA])
        #expect(await restoredQueue.allPending(userId: userB) == [operationB])
    }

    @Test("marking the first operation succeeded only affects that user's queue")
    func markFirstSucceededIsScopedByUser() async throws {
        let userDefaults = makeUserDefaults()
        let queue = OfflineOperationQueueLocal(userDefaults: userDefaults, now: { now })
        let operationA = makeOperation(id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!, name: "Physics")
        let operationB = makeOperation(id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!, name: "Biology")

        try await queue.enqueue(operationA, userId: userA)
        try await queue.enqueue(operationB, userId: userB)

        try await queue.markFirstSucceeded(operationA.id, userId: userA)

        #expect(await queue.allPending(userId: userA).isEmpty)
        #expect(await queue.allPending(userId: userB) == [operationB])
    }

    @Test("ensure restored updates restore state before queue usage")
    func ensureRestoredUpdatesState() async {
        let queue = OfflineOperationQueueLocal(userDefaults: makeUserDefaults(), now: { now })

        #expect(await queue.restoreState(for: userA) == .notStarted)

        await queue.ensureRestored(userId: userA)

        #expect(await queue.restoreState(for: userA) == .restored)
    }

    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "OfflineOperationQueueLocalTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }

    private func makeOperation(id: UUID, name: String) -> PendingOfflineOperation {
        PendingOfflineOperation(
            id: id,
            createdAt: now,
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: .createCategory(CreateCategoryDTO(name: name))
        )
    }
}

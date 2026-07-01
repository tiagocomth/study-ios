//
//  StudySessionTrackerLocalTests.swift
//  StudyTests
//

import Testing
import Foundation
@testable import Study

@Suite("StudySessionTrackerLocal", .serialized)
struct StudySessionTrackerLocalTests {
    private let userA = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    private let userB = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    private let categoryId = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!
    private let sessionId = UUID(uuidString: "44444444-4444-4444-4444-444444444444")!
    private let now = Date(timeIntervalSince1970: 1_719_324_800)

    @Test("restores only the scoped user's session")
    func restoresSessionForMatchingUserOnly() async throws {
        let userDefaults = makeUserDefaults()
        let tracker = StudySessionTrackerLocal(
            userDefaults: userDefaults,
            now: { now },
            makeId: { sessionId }
        )

        _ = try await tracker.start(categoryId: categoryId, userId: userA, mode: .stopwatch)

        let restoredTracker = StudySessionTrackerLocal(userDefaults: userDefaults)
        await restoredTracker.ensureRestored(userId: userA)
        await restoredTracker.ensureRestored(userId: userB)

        let restoredSession = await restoredTracker.getActiveSession(userId: userA)

        #expect(restoredSession?.sessionId == sessionId)
        #expect(await restoredTracker.getActiveSession(userId: userB) == nil)
    }

    @Test("clearing one user does not remove another user's session")
    func clearIsScopedByUser() async throws {
        let userDefaults = makeUserDefaults()
        let tracker = StudySessionTrackerLocal(userDefaults: userDefaults)

        _ = try await tracker.start(categoryId: categoryId, userId: userA, mode: .stopwatch)
        _ = try await tracker.start(
            categoryId: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
            userId: userB,
            mode: .stopwatch
        )

        await tracker.clear(userId: userB)

        #expect(await tracker.getActiveSession(userId: userA) != nil)
        #expect(await tracker.getActiveSession(userId: userB) == nil)
    }

    @Test("ensure restored promotes restore state and exposes missing session as nil")
    func ensureRestoredUpdatesState() async {
        let tracker = StudySessionTrackerLocal(userDefaults: makeUserDefaults())

        #expect(await tracker.restoreState(for: userA) == .notStarted)

        await tracker.ensureRestored(userId: userA)

        #expect(await tracker.restoreState(for: userA) == .restored)
        #expect(await tracker.getActiveSession(userId: userA) == nil)
    }

    @Test("countdown session keeps expected end date only while running")
    func countdownExpectedEndDateFollowsRunningState() async throws {
        var currentDate = now
        let tracker = StudySessionTrackerLocal(
            userDefaults: makeUserDefaults(),
            now: { now },
            makeId: { UUID() }
        )

        _ = try await tracker.start(
            categoryId: categoryId,
            userId: userA,
            mode: .countdown(durationSeconds: 300)
        )

        var session = await tracker.getActiveSession(userId: userA)
        #expect(session?.expectedEndDate == now.addingTimeInterval(300))
        #expect(session?.countdownDurationSeconds == 300)

        currentDate = now.addingTimeInterval(120)
        _ = try await tracker.pause(userId: userA)

        session = await tracker.getActiveSession(userId: userA)
        #expect(session?.expectedEndDate == nil)

        currentDate = now.addingTimeInterval(180)
        _ = try await tracker.resume(userId: userA)

        session = await tracker.getActiveSession(userId: userA)
        #expect(session?.expectedEndDate == currentDate.addingTimeInterval(180))
    }

    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "StudySessionTrackerLocalTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}

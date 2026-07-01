//
//  StudySessionSyncServiceTests.swift
//  StudyTests
//

import Foundation
import Testing
@testable import Study

@MainActor
@Suite("StudySessionSyncService", .serialized)
struct StudySessionSyncServiceTests {
    private let userId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    private let sessionId = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    private let categoryId = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

    @Test("pulls the active backend session when the queue is empty")
    func refreshesActiveSessionFromBackend() async throws {
        let activeSession = makeActiveSessionDTO()
        let studySessionAPI = StudySessionAPIStub(lastSession: activeSession)
        let tracker = StudySessionTrackerSpy()
        let queue = OfflineOperationQueueSpy(peekResult: nil)
        let timerModeStore = StudySessionTimerModeStoreSpy()
        let service = StudySessionSyncService(
            studySessionAPI: studySessionAPI,
            studySessionTracker: tracker,
            offlineOperationQueue: queue,
            timerModeStore: timerModeStore
        )

        try await service.refreshFromBackendIfQueueIsEmpty(userId: userId)

        let savedSession = await tracker.savedSession

        #expect(await studySessionAPI.lastCallCount == 1)
        #expect(savedSession?.sessionId == sessionId)
        #expect(savedSession?.categoryId == categoryId)
        #expect(savedSession?.state == .paused)
        #expect(savedSession?.pauses.count == 1)
        #expect(savedSession?.startDate == ISO8601DateParser().parse("2026-06-30T12:00:00Z"))
        #expect(await timerModeStore.savedMode == .stopwatch)
    }

    @Test("skips refresh when there are pending offline operations")
    func skipsRefreshWhenQueueHasPendingOperations() async throws {
        let studySessionAPI = StudySessionAPIStub(lastSession: makeActiveSessionDTO())
        let tracker = StudySessionTrackerSpy()
        let queue = OfflineOperationQueueSpy(peekResult: PendingOfflineOperation(
            id: UUID(),
            createdAt: Date(),
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: .deleteCategory(UUID())
        ))
        let timerModeStore = StudySessionTimerModeStoreSpy()
        let service = StudySessionSyncService(
            studySessionAPI: studySessionAPI,
            studySessionTracker: tracker,
            offlineOperationQueue: queue,
            timerModeStore: timerModeStore
        )

        try await service.refreshFromBackendIfQueueIsEmpty(userId: userId)

        #expect(await studySessionAPI.lastCallCount == 0)
        #expect(await tracker.savedSession == nil)
    }

    @Test("clears local session when backend has no active session")
    func clearsLocalSessionWhenBackendHasNoActiveSession() async throws {
        let studySessionAPI = StudySessionAPIStub(lastSession: nil)
        let tracker = StudySessionTrackerSpy()
        let queue = OfflineOperationQueueSpy(peekResult: nil)
        let timerModeStore = StudySessionTimerModeStoreSpy()
        let service = StudySessionSyncService(
            studySessionAPI: studySessionAPI,
            studySessionTracker: tracker,
            offlineOperationQueue: queue,
            timerModeStore: timerModeStore
        )

        try await service.refreshFromBackendIfQueueIsEmpty(userId: userId)

        #expect(await studySessionAPI.lastCallCount == 1)
        #expect(await tracker.clearCallCount == 1)
        #expect(await tracker.savedSession == nil)
        #expect(await timerModeStore.clearCallCount == 1)
    }

    @Test("preserves the local paused state when backend returns the same active session")
    func preservesLocalPausedStateWhenRefreshingSameSession() async throws {
        let studySessionAPI = StudySessionAPIStub(lastSession: makeActiveSessionDTO())
        let tracker = StudySessionTrackerSpy(
            activeSession: LocalStudySession(
                sessionId: sessionId,
                categoryId: categoryId,
                startDate: ISO8601DateParser().parse("2026-06-30T12:00:00Z")!,
                endDate: nil,
                expectedEndDate: ISO8601DateParser().parse("2026-06-30T13:00:00Z"),
                countdownDurationSeconds: 3600,
                state: .paused,
                pauses: [
                    LocalStudyPause(
                        pauseId: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                        startedAt: ISO8601DateParser().parse("2026-06-30T12:15:00Z")!,
                        endedAt: nil
                    )
                ]
            )
        )
        let queue = OfflineOperationQueueSpy(peekResult: nil)
        let timerModeStore = StudySessionTimerModeStoreSpy(mode: .countdown(durationSeconds: 3600))
        let service = StudySessionSyncService(
            studySessionAPI: studySessionAPI,
            studySessionTracker: tracker,
            offlineOperationQueue: queue,
            timerModeStore: timerModeStore
        )

        try await service.refreshFromBackendIfQueueIsEmpty(userId: userId)

        let savedSession = await tracker.savedSession

        #expect(savedSession?.state == .paused)
        #expect(savedSession?.pauses.count == 1)
        #expect(savedSession?.pauses.first?.endedAt == nil)
        #expect(savedSession?.expectedEndDate == ISO8601DateParser().parse("2026-06-30T13:00:00Z"))
        #expect(savedSession?.countdownDurationSeconds == 3600)
        #expect(await timerModeStore.savedMode == .countdown(durationSeconds: 3600))
    }
}

private extension StudySessionSyncServiceTests {
    func makeActiveSessionDTO() -> StudySessionDTO {
        StudySessionDTO(
            sessionId: sessionId.uuidString,
            userId: userId.uuidString,
            categoryId: categoryId.uuidString,
            startedAt: "2026-06-30T12:00:00Z",
            endedAt: nil,
            duration: 1800,
            category: StudyCategoryDTO(
                categoryId: categoryId.uuidString,
                userId: userId.uuidString,
                name: "Math",
                createdAt: "2026-06-30T12:00:00Z",
                isDeleted: false
            ),
            pauses: [
                StudySessionPauseDTO(
                    pauseId: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!.uuidString,
                    studySessionId: sessionId.uuidString,
                    startedAt: "2026-06-30T12:15:00Z",
                    endedAt: nil
                )
            ]
        )
    }

}

private actor StudySessionAPIStub: StudySessionAPIProtocol {
    private let lastSession: StudySessionDTO?
    private(set) var lastCallCount = 0

    init(lastSession: StudySessionDTO?) {
        self.lastSession = lastSession
    }

    func last() async throws(NetworkError) -> StudySessionDTO? {
        lastCallCount += 1
        return lastSession
    }

    func start(_ dto: StartStudySessionDTO) async throws(NetworkError) {}
    func pause(id: UUID, dto: PauseStudySessionDTO) async throws(NetworkError) {}
    func resume(id: UUID, dto: ResumeStudySessionDTO) async throws(NetworkError) {}
    func finish(id: UUID, dto: EndStudySessionDTO) async throws(NetworkError) {}
    func delete(id: UUID) async throws(NetworkError) {}
}

private actor StudySessionTrackerSpy: StudySessionTrackerLocalProtocol {
    private(set) var savedSession: LocalStudySession?
    private(set) var clearCallCount = 0

    init(activeSession: LocalStudySession? = nil) {
        self.savedSession = activeSession
    }

    func sessionChanges(userId: UUID) async -> AsyncStream<LocalStudySession?> {
        AsyncStream { continuation in
            continuation.yield(nil)
            continuation.finish()
        }
    }

    func restoreState(for userId: UUID) async -> RestoreState { .restored }
    func ensureRestored(userId: UUID) async {}
    func getActiveSession(userId: UUID) async -> LocalStudySession? { savedSession }

    func save(_ session: LocalStudySession, userId: UUID) async throws(StudySessionTrackerLocalError) {
        savedSession = session
    }

    func start(categoryId: UUID, userId: UUID, mode: StudySessionTimerMode) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction {
        throw .sessionNotFound
    }

    func pause(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction { throw .sessionNotFound }
    func resume(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction { throw .sessionNotFound }
    func finish(userId: UUID, endDate: Date?) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction { throw .sessionNotFound }
    func clear(userId: UUID) async {
        clearCallCount += 1
        savedSession = nil
    }
}

private actor OfflineOperationQueueSpy: OfflineOperationQueueLocalProtocol {
    private let peekResult: PendingOfflineOperation?

    init(peekResult: PendingOfflineOperation?) {
        self.peekResult = peekResult
    }

    func restoreState(for userId: UUID) async -> RestoreState { .restored }
    func ensureRestored(userId: UUID) async {}
    func enqueue(_ operation: PendingOfflineOperation, userId: UUID) async throws(OfflineOperationQueueLocalError) {}
    func peek(userId: UUID) async -> PendingOfflineOperation? { peekResult }
    func allPending(userId: UUID) async -> [PendingOfflineOperation] { peekResult.map { [$0] } ?? [] }
    func markFirstSucceeded(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError) {}
    func markFirstFailed(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError) {}
    func removeOperation(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError) {}
    func clear(userId: UUID) async throws(OfflineOperationQueueLocalError) {}
}

private actor StudySessionTimerModeStoreSpy: StudySessionTimerModeStoreLocalProtocol {
    private(set) var savedMode: StudySessionTimerMode?
    private(set) var clearCallCount = 0

    init(mode: StudySessionTimerMode? = nil) {
        self.savedMode = mode
    }

    func restoreState(for userId: UUID) async -> RestoreState { .restored }
    func ensureRestored(userId: UUID) async {}
    func getMode(userId: UUID) async -> StudySessionTimerMode? { savedMode }

    func saveMode(_ mode: StudySessionTimerMode, userId: UUID) async {
        savedMode = mode
    }

    func clear(userId: UUID) async {
        clearCallCount += 1
        savedMode = nil
    }
}

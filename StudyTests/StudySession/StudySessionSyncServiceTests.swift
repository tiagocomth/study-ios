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
        let service = StudySessionSyncService(
            studySessionAPI: studySessionAPI,
            studySessionTracker: tracker,
            offlineOperationQueue: queue
        )

        try await service.refreshFromBackendIfQueueIsEmpty(userId: userId)

        let savedSession = await tracker.savedSession

        #expect(await studySessionAPI.lastCallCount == 1)
        #expect(savedSession?.sessionId == sessionId)
        #expect(savedSession?.categoryId == categoryId)
        #expect(savedSession?.state == .running)
        #expect(savedSession?.startDate == ISO8601DateParser().parse("2026-06-30T12:00:00Z"))
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
        let service = StudySessionSyncService(
            studySessionAPI: studySessionAPI,
            studySessionTracker: tracker,
            offlineOperationQueue: queue
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
        let service = StudySessionSyncService(
            studySessionAPI: studySessionAPI,
            studySessionTracker: tracker,
            offlineOperationQueue: queue
        )

        try await service.refreshFromBackendIfQueueIsEmpty(userId: userId)

        #expect(await studySessionAPI.lastCallCount == 1)
        #expect(await tracker.clearCallCount == 1)
        #expect(await tracker.savedSession == nil)
    }
}

private extension StudySessionSyncServiceTests {
    func makeActiveSessionDTO() -> StudySessionDTO {
        StudySessionDTO(
            sessionId: sessionId.uuidString,
            userId: userId.uuidString,
            categoryId: categoryId.uuidString,
            startedAt: "2026-06-30T12:00:00Z",
            endedAt: nil
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

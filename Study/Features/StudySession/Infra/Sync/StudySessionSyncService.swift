//
//  StudySessionSyncService.swift
//  Study
//

import Foundation

@MainActor
final class StudySessionSyncService: StudySessionSyncServiceProtocol {
    private let studySessionAPI: StudySessionAPIProtocol
    private let studySessionTracker: StudySessionTrackerLocalProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let timerModeStore: StudySessionTimerModeStoreLocalProtocol
    
    init(
        studySessionAPI: StudySessionAPIProtocol,
        studySessionTracker: StudySessionTrackerLocalProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        timerModeStore: StudySessionTimerModeStoreLocalProtocol
    ) {
        self.studySessionAPI = studySessionAPI
        self.studySessionTracker = studySessionTracker
        self.offlineOperationQueue = offlineOperationQueue
        self.timerModeStore = timerModeStore
    }
    
    func refreshFromBackendIfQueueIsEmpty(userId: UUID) async throws {
        await studySessionTracker.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }
        let localSession = await studySessionTracker.getActiveSession(userId: userId)

        let backendSession = try await studySessionAPI.last()
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }
        
        guard
            let backendSession,
            backendSession.isActiveBackendSession,
            let activeSession = mergedSession(localSession: localSession, backendSession: backendSession)
        else {
            await studySessionTracker.clear(userId: userId)
            await timerModeStore.clear(userId: userId)
            return
        }
        
        try await studySessionTracker.save(activeSession, userId: userId)
        await syncTimerMode(for: activeSession, previousSession: localSession, userId: userId)
    }
}

private extension StudySessionSyncService {
    func mergedSession(
        localSession: LocalStudySession?,
        backendSession: StudySessionDTO
    ) -> LocalStudySession? {
        guard let backendLocalSession = backendSession.toLocalStudySession() else { return nil }

        guard let localSession, localSession.sessionId == backendLocalSession.sessionId else {
            return backendLocalSession
        }

        return LocalStudySession(
            sessionId: backendLocalSession.sessionId,
            categoryId: backendLocalSession.categoryId,
            startDate: backendLocalSession.startDate,
            endDate: backendLocalSession.endDate,
            expectedEndDate: localSession.expectedEndDate,
            countdownDurationSeconds: localSession.countdownDurationSeconds,
            state: backendLocalSession.state,
            pauses: backendLocalSession.pauses
        )
    }

    // Se eu recuperei um sessão do backend e ela não é a mesma, então vou tratar o backend como verdade, porém não tem como saber se era stopwatch ou countdown, vou lidar como stopwatch por default porque é mais simples
    func syncTimerMode(
        for activeSession: LocalStudySession,
        previousSession: LocalStudySession?,
        userId: UUID
    ) async {
        guard previousSession?.sessionId == activeSession.sessionId else {
            await timerModeStore.saveMode(.stopwatch, userId: userId)
            return
        }
    }
}

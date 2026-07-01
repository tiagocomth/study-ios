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
    
    init(
        studySessionAPI: StudySessionAPIProtocol,
        studySessionTracker: StudySessionTrackerLocalProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol
    ) {
        self.studySessionAPI = studySessionAPI
        self.studySessionTracker = studySessionTracker
        self.offlineOperationQueue = offlineOperationQueue
    }
    
    func refreshFromBackendIfQueueIsEmpty(userId: UUID) async throws {
        await studySessionTracker.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }
        
        let backendSession = try await studySessionAPI.last()
        guard await offlineOperationQueue.peek(userId: userId) == nil else { return }
        
        guard
            let backendSession,
            backendSession.isActiveBackendSession,
            let activeSession = backendSession.toLocalStudySession()
        else {
            await studySessionTracker.clear(userId: userId)
            return
        }
        
        try await studySessionTracker.save(activeSession, userId: userId)
    }
    
}

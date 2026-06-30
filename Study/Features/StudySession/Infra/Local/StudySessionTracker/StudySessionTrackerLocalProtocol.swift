//
//  StudySessionTrackerLocalProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionTrackerLocalProtocol {
    func sessionChanges(userId: UUID) async -> AsyncStream<LocalStudySession?>
    func restoreState(for userId: UUID) async -> RestoreState
    func ensureRestored(userId: UUID) async
    func getActiveSession(userId: UUID) async -> LocalStudySession?
    func start(categoryId: UUID, userId: UUID, mode: StudySessionTimerMode) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func pause(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func resume(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func finish(userId: UUID, endDate: Date?) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func clear(userId: UUID) async
}

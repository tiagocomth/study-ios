//
//  StudySessionTrackerLocalProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionTrackerLocalProtocol {
    func getActiveSession(userId: UUID) async -> LocalStudySession?
    func restore(userId: UUID) async // TODO: Ver quem vai usar esse cara
    func start(categoryId: UUID, userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func pause(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func resume(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func finish(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func clear(userId: UUID) async
}

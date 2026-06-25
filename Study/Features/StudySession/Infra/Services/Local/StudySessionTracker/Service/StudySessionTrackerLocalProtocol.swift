//
//  StudySessionTrackerLocalProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionTrackerLocalProtocol {
    func getActiveSession() async -> LocalStudySession?
    func restore() async // TODO: Ver quem vai usar esse cara
    func start(categoryId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func pause() async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func resume() async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func finish() async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction
    func clear() async
}

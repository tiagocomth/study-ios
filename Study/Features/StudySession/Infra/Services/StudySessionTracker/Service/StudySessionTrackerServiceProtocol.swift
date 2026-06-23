//
//  StudySessionTrackerServiceProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionTrackerServiceProtocol {
    func getActiveSession() async -> LocalStudySession?
    func restore() async
    func start(categoryId: String) async throws(StudySessionTrackerError) -> StudySessionTrackerAction
    func pause() async throws(StudySessionTrackerError) -> StudySessionTrackerAction
    func resume() async throws(StudySessionTrackerError) -> StudySessionTrackerAction
    func finish() async throws(StudySessionTrackerError) -> StudySessionTrackerAction
    func clear() async
}

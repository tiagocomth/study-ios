//
//  StudySessionTrackerOrchestrationProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionTrackerOrchestrationProtocol {
    func getActiveSession() async -> LocalStudySession?
    func start(categoryId: UUID) async throws
    func pause() async throws
    func resume() async throws
    func finish() async throws
}

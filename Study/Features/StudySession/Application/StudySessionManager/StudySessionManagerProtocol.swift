//
//  StudySessionManagerProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionManagerProtocol {
    func activeSessionChanges() async -> AsyncStream<LocalStudySession?>
    func getActiveSession() async -> LocalStudySession?
    func start(categoryId: UUID, mode: StudySessionTimerMode) async throws
    func pause() async throws
    func resume() async throws
    func finish(endDate: Date?) async throws
}

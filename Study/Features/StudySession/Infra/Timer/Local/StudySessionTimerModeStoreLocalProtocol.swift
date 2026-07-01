//
//  StudySessionTimerModeStoreLocalProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionTimerModeStoreLocalProtocol {
    func restoreState(for userId: UUID) async -> RestoreState
    func ensureRestored(userId: UUID) async
    func getMode(userId: UUID) async -> StudySessionTimerMode?
    func saveMode(_ mode: StudySessionTimerMode, userId: UUID) async
    func clear(userId: UUID) async
}

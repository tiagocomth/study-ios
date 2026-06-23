//
//  PendingOfflineOperationKind.swift
//  Study
//

import Foundation

nonisolated enum PendingOfflineOperationKind: Codable, Equatable, Sendable {
    case startStudySession(StartStudySessionDTO)
    case pauseStudySession(PauseStudySessionDTO)
    case resumeStudySession(ResumeStudySessionDTO)
    case endStudySession(EndStudySessionDTO)
}

//
//  StudySessionTrackerAction.swift
//  Study
//

import Foundation

nonisolated enum StudySessionTrackerAction: Equatable, Sendable {
    case started(StartStudySessionDTO)
    case paused(sessionId: UUID, dto: PauseStudySessionDTO)
    case resumed(sessionId: UUID, dto: ResumeStudySessionDTO)
    case finished(sessionId: UUID, dto: EndStudySessionDTO)
    case resumedAndFinished(sessionId: UUID, resume: ResumeStudySessionDTO, end: EndStudySessionDTO)
}

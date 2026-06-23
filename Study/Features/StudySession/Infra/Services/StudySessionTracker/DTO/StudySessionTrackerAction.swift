//
//  StudySessionTrackerAction.swift
//  Study
//

import Foundation

nonisolated enum StudySessionTrackerAction: Equatable, Sendable {
    case started(StartStudySessionDTO)
    case paused(PauseStudySessionDTO)
    case resumed(ResumeStudySessionDTO)
    case finished(EndStudySessionDTO)
    case resumedAndFinished(resume: ResumeStudySessionDTO, end: EndStudySessionDTO)
}

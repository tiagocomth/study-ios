//
//  StudySessionTrackerLocalError.swift
//  Study
//

import Foundation

nonisolated enum StudySessionTrackerLocalError: LocalizedError, Equatable, Sendable {
    case activeSessionAlreadyExists
    case sessionNotFound
    case sessionAlreadyPaused
    case sessionIsNotPaused
    case sessionAlreadyFinished
    case pauseNotFound
    case multipleOpenPausesFound
    case openPauseIsNotLatest
    case failedToPersistSession

    var errorDescription: String? {
        switch self {
        case .activeSessionAlreadyExists:
            return "There is already an active study session."
        case .sessionNotFound:
            return "No active study session was found."
        case .sessionAlreadyPaused:
            return "The study session is already paused."
        case .sessionIsNotPaused:
            return "The study session is not paused."
        case .sessionAlreadyFinished:
            return "The study session is already finished."
        case .pauseNotFound:
            return "No open pause was found."
        case .multipleOpenPausesFound:
            return "More than one open pause was found."
        case .openPauseIsNotLatest:
            return "The open pause is not the latest pause."
        case .failedToPersistSession:
            return "Failed to persist the study session."
        }
    }
}

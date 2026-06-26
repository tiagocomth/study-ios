//
//  StudySessionState.swift
//  Study
//

import Foundation

nonisolated enum StudySessionState: String, Codable, Equatable, Sendable {
    case running
    case paused
    case finished
}

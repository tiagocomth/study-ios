//
//  StudySessionTimerMode.swift
//  Study
//

import Foundation

nonisolated enum StudySessionTimerMode: Codable, Equatable, Sendable {
    case stopwatch
    case countdown(durationSeconds: Int)
}

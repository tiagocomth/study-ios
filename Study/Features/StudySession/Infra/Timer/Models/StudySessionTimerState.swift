//
//  StudySessionTimerState.swift
//  Study
//

import Foundation

struct StudySessionTimerState: Equatable, Sendable {
    let mode: StudySessionTimerMode
    let elapsedSeconds: Int
    let remainingSeconds: Int?
    let isRunning: Bool
}

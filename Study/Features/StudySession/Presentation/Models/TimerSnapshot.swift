//
//  TimerSnapshot.swift
//  Study
//

import Foundation

struct TimerSnapshot: Equatable {
    let mode: StudySessionTimerMode
    let elapsedSeconds: Int
    let remainingSeconds: Int?
}

//
//  TimerViewState.swift
//  Study
//

import Foundation

enum TimerViewState: Equatable {
    case notStarted
    case running(TimerSnapshot)
    case paused(TimerSnapshot)
    case finished(TimerSnapshot)
}

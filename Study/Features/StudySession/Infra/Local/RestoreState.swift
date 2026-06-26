//
//  RestoreState.swift
//  Study
//

import Foundation

nonisolated enum RestoreState: Equatable, Sendable {
    case notStarted
    case restoring
    case restored
    case failed
}

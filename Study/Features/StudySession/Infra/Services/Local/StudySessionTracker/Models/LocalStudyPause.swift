//
//  LocalStudyPause.swift
//  Study
//

import Foundation

nonisolated struct LocalStudyPause: Codable, Equatable, Sendable {
    let pauseId: UUID
    let startedAt: Date
    var endedAt: Date?
}

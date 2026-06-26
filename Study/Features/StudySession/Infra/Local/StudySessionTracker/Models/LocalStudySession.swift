//
//  LocalStudySession.swift
//  Study
//

import Foundation

nonisolated struct LocalStudySession: Codable, Equatable, Sendable {
    let sessionId: UUID
    let categoryId: UUID
    let startDate: Date
    var endDate: Date?
    var state: StudySessionState
    var pauses: [LocalStudyPause]
}

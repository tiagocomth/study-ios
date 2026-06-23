//
//  ResumeStudySessionDTO.swift
//  Study
//

import Foundation

nonisolated struct ResumeStudySessionDTO: Equatable, Sendable {
    let sessionId: UUID
    let endedAt: Date
}

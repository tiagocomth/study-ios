//
//  EndStudySessionDTO.swift
//  Study
//

import Foundation

nonisolated struct EndStudySessionDTO: Codable, Equatable, Sendable {
    let sessionId: UUID
    let endDate: Date
}

//
//  EndStudySessionDTO.swift
//  Study
//

import Foundation

nonisolated struct EndStudySessionDTO: Equatable, Sendable {
    let sessionId: UUID
    let endDate: Date
}

//
//  StartStudySessionDTO.swift
//  Study
//

import Foundation

nonisolated struct StartStudySessionDTO: Codable, Equatable, Sendable {
    let sessionId: UUID
    let startDate: Date
    let categoryId: UUID
}

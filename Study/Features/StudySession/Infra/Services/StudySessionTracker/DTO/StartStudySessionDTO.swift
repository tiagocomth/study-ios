//
//  StartStudySessionDTO.swift
//  Study
//

import Foundation

nonisolated struct StartStudySessionDTO: Equatable, Sendable {
    let sessionId: UUID
    let startDate: Date
    let categoryId: String?
}

//
//  PauseStudySessionDTO.swift
//  Study
//

import Foundation

nonisolated struct PauseStudySessionDTO: Equatable, Sendable {
    let sessionId: UUID
    let pauseId: UUID
    let startedAt: Date
}

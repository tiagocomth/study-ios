//
//  StudySessionSyncServiceProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol StudySessionSyncServiceProtocol {
    func refreshFromBackendIfQueueIsEmpty(userId: UUID) async throws
}

//
//  CategorySyncServiceProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol CategorySyncServiceProtocol {
    func refreshFromBackendIfQueueIsEmpty(userId: UUID) async throws
}

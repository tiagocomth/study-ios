//
//  PendingOfflineOperation.swift
//  Study
//

import Foundation

nonisolated struct PendingOfflineOperation: Codable, Equatable, Sendable {
    let id: UUID
    let createdAt: Date
    var lastAttemptAt: Date?
    var attemptCount: Int
    let kind: PendingOfflineOperationKind
}

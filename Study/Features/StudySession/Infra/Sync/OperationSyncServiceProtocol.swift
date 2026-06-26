//
//  OperationSyncServiceProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol OperationSyncServiceProtocol {
    func sync() async throws -> OperationSyncResult
}

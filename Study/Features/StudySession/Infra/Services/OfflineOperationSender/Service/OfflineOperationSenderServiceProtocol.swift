//
//  OfflineOperationSenderServiceProtocol.swift
//  Study
//

import Foundation

nonisolated protocol OfflineOperationSenderServiceProtocol {
    func send(_ operation: PendingOfflineOperation) async throws(NetworkError)
}

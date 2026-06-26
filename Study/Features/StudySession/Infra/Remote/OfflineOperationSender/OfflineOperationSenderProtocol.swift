//
//  OfflineOperationSenderProtocol.swift
//  Study
//

import Foundation

nonisolated protocol OfflineOperationSenderProtocol {
    func send(_ operation: PendingOfflineOperation) async throws(NetworkError)
}

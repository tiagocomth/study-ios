//
//  OfflineOperationSenderRemoteProtocol.swift
//  Study
//

import Foundation

nonisolated protocol OfflineOperationSenderRemoteProtocol {
    func send(_ operation: PendingOfflineOperation) async throws(NetworkError)
}

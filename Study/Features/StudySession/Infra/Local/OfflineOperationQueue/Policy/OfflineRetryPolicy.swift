//
//  OfflineRetryPolicy.swift
//  Study
//

import Foundation

nonisolated struct OfflineRetryPolicy {
    static func shouldEnqueue(_ error: NetworkError) -> Bool {
        switch error {
        case .network, .noResponse:
            true
        case .invalidStatusCode(let codeStatus, _):
            (500...599).contains(codeStatus)
        default:
            false
        }
    }
}

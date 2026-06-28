//
//  OfflineOperationQueueLocalError.swift
//  Study
//

import Foundation

nonisolated enum OfflineOperationQueueLocalError: LocalizedError, Equatable, Sendable {
    case queueIsEmpty
    case operationIsNotFirst
    case failedToPersistOperations
    case notFound

    var errorDescription: String? {
        switch self {
        case .queueIsEmpty:
            return "There are no pending offline operations."
        case .operationIsNotFirst:
            return "Only the first pending offline operation can be updated."
        case .failedToPersistOperations:
            return "Failed to persist pending offline operations."
        case .notFound:
            return "The pending offline operation was not found."
        }
    }
}

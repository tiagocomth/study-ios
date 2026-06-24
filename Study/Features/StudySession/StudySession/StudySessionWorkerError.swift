//
//  StudySessionWorkerError.swift
//  Study
//

import Foundation

nonisolated enum StudySessionWorkerError: LocalizedError, Equatable, Sendable {
    case missingCurrentUser
    case categoryNotFound

    var errorDescription: String? {
        switch self {
        case .missingCurrentUser:
            "Missing current user."
        case .categoryNotFound:
            "Category not found."
        }
    }
}

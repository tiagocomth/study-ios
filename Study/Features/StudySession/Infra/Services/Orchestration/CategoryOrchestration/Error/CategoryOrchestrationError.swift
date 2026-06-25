//
//  CategoryOrchestrationError.swift
//  Study
//

import Foundation

nonisolated enum CategoryOrchestrationError: LocalizedError, Equatable, Sendable {
    case missingCurrentUser
    case categoryNotFound
    
    var errorDescription: String? {
        switch self {
        case .missingCurrentUser:
            return "Current user was not found."
        case .categoryNotFound:
            return "Category was not found."
        }
    }
}

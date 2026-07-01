//
//  StudySessionError.swift
//  Study
//

import Foundation

nonisolated enum StudySessionError: LocalizedError, Equatable, Sendable {
    case missingCurrentUser
    case categoryNotFound
    case invalidCategoryName
    case studySessionTimerNotConfigured

    var errorDescription: String? {
        switch self {
        case .missingCurrentUser:
            "Missing current user."
        case .categoryNotFound:
            "Category not found."
        case .invalidCategoryName:
            "Category name cannot be empty."
        case .studySessionTimerNotConfigured:
            "Study session timer is not configured."
        }
    }
}

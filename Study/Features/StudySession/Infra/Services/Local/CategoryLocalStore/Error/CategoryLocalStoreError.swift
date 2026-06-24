//
//  CategoryLocalStoreError.swift
//  Study
//

import Foundation

nonisolated enum CategoryLocalStoreError: LocalizedError, Equatable, Sendable {
    case failedToFetchCategories
    case failedToSaveCategory
    case failedToDeleteCategory
    case failedToRollbackCategory

    var errorDescription: String? {
        switch self {
        case .failedToFetchCategories:
            "Failed to fetch local categories."
        case .failedToSaveCategory:
            "Failed to save local category."
        case .failedToDeleteCategory:
            "Failed to delete local category."
        case .failedToRollbackCategory:
            "Failed to rollback local category."
        }
    }
}

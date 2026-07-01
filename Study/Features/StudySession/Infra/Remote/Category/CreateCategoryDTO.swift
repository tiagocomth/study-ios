//
//  CreateCategoryDTO.swift
//  Study
//

import Foundation

nonisolated struct CreateCategoryDTO: Codable, Equatable, Sendable {
    let categoryId: UUID
    let name: String
}

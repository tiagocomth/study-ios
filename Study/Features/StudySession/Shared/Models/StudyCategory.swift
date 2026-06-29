//
//  StudyCategory.swift
//  Study
//

import Foundation

nonisolated struct StudyCategory: Decodable, Equatable, Sendable {
    let categoryId: UUID
    let userId: UUID
    let name: String
    let createdAt: String
}

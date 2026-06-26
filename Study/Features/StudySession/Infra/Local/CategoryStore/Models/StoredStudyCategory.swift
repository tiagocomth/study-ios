//
//  StoredStudyCategory.swift
//  Study
//

import Foundation
import SwiftData

@Model
final class StoredStudyCategory {
    @Attribute(.unique) var categoryId: UUID
    var userId: UUID
    var name: String
    var createdAt: String

    init(categoryId: UUID, userId: UUID, name: String, createdAt: String) {
        self.categoryId = categoryId
        self.userId = userId
        self.name = name
        self.createdAt = createdAt
    }

    convenience init(category: StudyCategory) {
        self.init(
            categoryId: category.categoryId,
            userId: category.userId,
            name: category.name,
            createdAt: category.createdAt
        )
    }

    func update(with category: StudyCategory) {
        userId = category.userId
        name = category.name
        createdAt = category.createdAt
    }

    func toStudyCategory() -> StudyCategory {
        StudyCategory(
            categoryId: categoryId,
            userId: userId,
            name: name,
            createdAt: createdAt
        )
    }
}

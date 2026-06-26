//
//  CategoryStoreLocal.swift
//  Study
//

import Foundation
import SwiftData

@MainActor
final class CategoryStoreLocal: CategoryStoreLocalProtocol {
    private let context: ModelContext
    private let logger: DomainLogging

    init(
        context: ModelContext,
        logger: DomainLogging = CategoryLogger()
    ) {
        self.context = context
        self.logger = logger
    }

    func getAll(userId: UUID) throws(CategoryStoreLocalError) -> [StudyCategory] {
        do {
            return try fetchAllStoredCategories(userId: userId).map { $0.toStudyCategory() }
        } catch {
            logger.error("Failed to fetch local categories")
            throw CategoryStoreLocalError.failedToFetchCategories
        }
    }

    func getById(_ id: UUID, userId: UUID) throws(CategoryStoreLocalError) -> StudyCategory? {
        do {
            return try fetchStoredCategory(id: id, userId: userId)?.toStudyCategory()
        } catch {
            logger.error("Failed to fetch local category \(id.uuidString)")
            throw CategoryStoreLocalError.failedToFetchCategories
        }
    }

    func saveAll(_ categories: [StudyCategory]) throws(CategoryStoreLocalError) {
        do {
            try categories.forEach { try saveCategory($0) }
            try context.save()
            logger.info("Saved \(categories.count) local categories")
        } catch {
            logger.error("Failed to save local categories")
            throw CategoryStoreLocalError.failedToSaveCategory
        }
    }

    func save(_ category: StudyCategory) throws(CategoryStoreLocalError) {
        do {
            try saveCategory(category)
            try context.save()
            logger.info("Saved local category \(category.categoryId.uuidString)")
        } catch {
            logger.error("Failed to save local category \(category.categoryId.uuidString)")
            throw CategoryStoreLocalError.failedToSaveCategory
        }
    }

    func delete(id: UUID, userId: UUID) throws(CategoryStoreLocalError) {
        do {
            if let category = try fetchStoredCategory(id: id, userId: userId) {
                context.delete(category)
                try context.save()
            }
            logger.info("Deleted local category \(id.uuidString)")
        } catch {
            logger.error("Failed to delete local category \(id.uuidString)")
            throw CategoryStoreLocalError.failedToDeleteCategory
        }
    }

    func rollbackCreate(id: UUID, userId: UUID) throws(CategoryStoreLocalError) {
        do {
            if let category = try fetchStoredCategory(id: id, userId: userId) {
                context.delete(category)
                try context.save()
            }
            logger.info("Rolled back local category create \(id.uuidString)")
        } catch {
            logger.error("Failed to rollback local category create \(id.uuidString)")
            throw CategoryStoreLocalError.failedToRollbackCategory
        }
    }

    func rollbackUpdate(previousCategory: StudyCategory) throws(CategoryStoreLocalError) {
        do {
            try saveCategory(previousCategory)
            try context.save()
            logger.info("Rolled back local category update \(previousCategory.categoryId.uuidString)")
        } catch {
            logger.error("Failed to rollback local category update \(previousCategory.categoryId.uuidString)")
            throw CategoryStoreLocalError.failedToRollbackCategory
        }
    }

    func rollbackDelete(deletedCategory: StudyCategory) throws(CategoryStoreLocalError) {
        do {
            try saveCategory(deletedCategory)
            try context.save()
            logger.info("Rolled back local category delete \(deletedCategory.categoryId.uuidString)")
        } catch {
            logger.error("Failed to rollback local category delete \(deletedCategory.categoryId.uuidString)")
            throw CategoryStoreLocalError.failedToRollbackCategory
        }
    }
}

private extension CategoryStoreLocal {
    func fetchAllStoredCategories(userId: UUID) throws -> [StoredStudyCategory] {
        let descriptor = FetchDescriptor<StoredStudyCategory>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try context.fetch(descriptor)
    }

    func fetchStoredCategory(id: UUID, userId: UUID) throws -> StoredStudyCategory? {
        let descriptor = FetchDescriptor<StoredStudyCategory>(
            predicate: #Predicate { $0.categoryId == id && $0.userId == userId }
        )
        return try context.fetch(descriptor).first
    }

    func saveCategory(_ category: StudyCategory) throws {
        if let storedCategory = try fetchStoredCategory(id: category.categoryId, userId: category.userId) {
            storedCategory.update(with: category)
            return
        }

        context.insert(StoredStudyCategory(category: category))
    }
}

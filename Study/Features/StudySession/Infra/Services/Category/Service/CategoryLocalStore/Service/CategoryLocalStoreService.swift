//
//  CategoryLocalStoreService.swift
//  Study
//

import Foundation
import SwiftData

@MainActor
final class CategoryLocalStoreService: CategoryLocalStoreServiceProtocol {
    private let context: ModelContext
    private let logger: DomainLogging

    init(
        context: ModelContext,
        logger: DomainLogging = CategoryLogger()
    ) {
        self.context = context
        self.logger = logger
    }

    func getAll() throws(CategoryLocalStoreError) -> [StudyCategory] {
        do {
            return try fetchAllStoredCategories().map { $0.toStudyCategory() }
        } catch {
            logger.error("Failed to fetch local categories")
            throw CategoryLocalStoreError.failedToFetchCategories
        }
    }

    func getById(_ id: UUID) throws(CategoryLocalStoreError) -> StudyCategory? {
        do {
            return try fetchStoredCategory(id: id)?.toStudyCategory()
        } catch {
            logger.error("Failed to fetch local category \(id.uuidString)")
            throw CategoryLocalStoreError.failedToFetchCategories
        }
    }

    func saveAll(_ categories: [StudyCategory]) throws(CategoryLocalStoreError) {
        do {
            try categories.forEach { try saveCategory($0) }
            try context.save()
            logger.info("Saved \(categories.count) local categories")
        } catch {
            logger.error("Failed to save local categories")
            throw CategoryLocalStoreError.failedToSaveCategory
        }
    }

    func save(_ category: StudyCategory) throws(CategoryLocalStoreError) {
        do {
            try saveCategory(category)
            try context.save()
            logger.info("Saved local category \(category.categoryId.uuidString)")
        } catch {
            logger.error("Failed to save local category \(category.categoryId.uuidString)")
            throw CategoryLocalStoreError.failedToSaveCategory
        }
    }

    func delete(id: UUID) throws(CategoryLocalStoreError) {
        do {
            if let category = try fetchStoredCategory(id: id) {
                context.delete(category)
                try context.save()
            }
            logger.info("Deleted local category \(id.uuidString)")
        } catch {
            logger.error("Failed to delete local category \(id.uuidString)")
            throw CategoryLocalStoreError.failedToDeleteCategory
        }
    }

    func rollbackCreate(id: UUID) throws(CategoryLocalStoreError) {
        do {
            if let category = try fetchStoredCategory(id: id) {
                context.delete(category)
                try context.save()
            }
            logger.info("Rolled back local category create \(id.uuidString)")
        } catch {
            logger.error("Failed to rollback local category create \(id.uuidString)")
            throw CategoryLocalStoreError.failedToRollbackCategory
        }
    }

    func rollbackUpdate(previousCategory: StudyCategory) throws(CategoryLocalStoreError) {
        do {
            try saveCategory(previousCategory)
            try context.save()
            logger.info("Rolled back local category update \(previousCategory.categoryId.uuidString)")
        } catch {
            logger.error("Failed to rollback local category update \(previousCategory.categoryId.uuidString)")
            throw CategoryLocalStoreError.failedToRollbackCategory
        }
    }

    func rollbackDelete(deletedCategory: StudyCategory) throws(CategoryLocalStoreError) {
        do {
            try saveCategory(deletedCategory)
            try context.save()
            logger.info("Rolled back local category delete \(deletedCategory.categoryId.uuidString)")
        } catch {
            logger.error("Failed to rollback local category delete \(deletedCategory.categoryId.uuidString)")
            throw CategoryLocalStoreError.failedToRollbackCategory
        }
    }
}

private extension CategoryLocalStoreService {
    func fetchAllStoredCategories() throws -> [StoredStudyCategory] {
        let descriptor = FetchDescriptor<StoredStudyCategory>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try context.fetch(descriptor)
    }

    func fetchStoredCategory(id: UUID) throws -> StoredStudyCategory? {
        let descriptor = FetchDescriptor<StoredStudyCategory>(
            predicate: #Predicate { $0.categoryId == id }
        )
        return try context.fetch(descriptor).first
    }

    func saveCategory(_ category: StudyCategory) throws {
        if let storedCategory = try fetchStoredCategory(id: category.categoryId) {
            storedCategory.update(with: category)
            return
        }

        context.insert(StoredStudyCategory(category: category))
    }
}

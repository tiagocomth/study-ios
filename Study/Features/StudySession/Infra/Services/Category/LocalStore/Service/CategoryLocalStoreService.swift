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
            let descriptor = FetchDescriptor<LocalStudyCategory>(
                sortBy: [SortDescriptor(\.createdAt)]
            )
            return try context.fetch(descriptor).map { $0.toStudyCategory() }
        } catch {
            logger.error("Failed to fetch local categories")
            throw CategoryLocalStoreError.failedToFetchCategories
        }
    }

    func getById(_ id: UUID) throws(CategoryLocalStoreError) -> StudyCategory? {
        do {
            return try fetchLocalCategory(id: id)?.toStudyCategory()
        } catch {
            logger.error("Failed to fetch local category \(id.uuidString)")
            throw CategoryLocalStoreError.failedToFetchCategories
        }
    }

    func upsert(_ category: StudyCategory) throws(CategoryLocalStoreError) {
        do {
            try upsertCategory(category)
            try context.save()
            logger.info("Saved local category \(category.categoryId.uuidString)")
        } catch {
            logger.error("Failed to save local category \(category.categoryId.uuidString)")
            throw CategoryLocalStoreError.failedToSaveCategory
        }
    }

    func upsert(_ categories: [StudyCategory]) throws(CategoryLocalStoreError) {
        do {
            try categories.forEach { try upsertCategory($0) }
            try context.save()
            logger.info("Saved \(categories.count) local categories")
        } catch {
            logger.error("Failed to save local categories")
            throw CategoryLocalStoreError.failedToSaveCategory
        }
    }

    func delete(id: UUID) throws(CategoryLocalStoreError) {
        do {
            if let category = try fetchLocalCategory(id: id) {
                context.delete(category)
                try context.save()
            }
            logger.info("Deleted local category \(id.uuidString)")
        } catch {
            logger.error("Failed to delete local category \(id.uuidString)")
            throw CategoryLocalStoreError.failedToDeleteCategory
        }
    }

    func replaceAll(with categories: [StudyCategory]) throws(CategoryLocalStoreError) {
        do {
            let descriptor = FetchDescriptor<LocalStudyCategory>()
            try context.fetch(descriptor).forEach { context.delete($0) }
            try categories.forEach { try upsertCategory($0) }
            try context.save()
            logger.info("Replaced local categories with \(categories.count) backend categories")
        } catch {
            logger.error("Failed to replace local categories")
            throw CategoryLocalStoreError.failedToReplaceCategories
        }
    }
}

private extension CategoryLocalStoreService {
    func fetchLocalCategory(id: UUID) throws -> LocalStudyCategory? {
        let descriptor = FetchDescriptor<LocalStudyCategory>(
            predicate: #Predicate { $0.categoryId == id }
        )
        return try context.fetch(descriptor).first
    }

    func upsertCategory(_ category: StudyCategory) throws {
        if let localCategory = try fetchLocalCategory(id: category.categoryId) {
            localCategory.update(with: category)
            return
        }

        context.insert(LocalStudyCategory(category: category))
    }
}

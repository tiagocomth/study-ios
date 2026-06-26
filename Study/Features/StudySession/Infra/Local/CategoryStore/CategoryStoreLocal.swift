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
    private var restoreStatesByUser: [UUID: RestoreState]
    private var categoryChangeContinuationsByUser: [UUID: [UUID: AsyncStream<[StudyCategory]>.Continuation]]

    init(
        context: ModelContext,
        logger: DomainLogging = CategoryLogger()
    ) {
        self.context = context
        self.logger = logger
        self.restoreStatesByUser = [:]
        self.categoryChangeContinuationsByUser = [:]
    }

    func categoryChanges(userId: UUID) -> AsyncStream<[StudyCategory]> {
        let streamId = UUID()

        return AsyncStream { continuation in
            var continuationsForUser = categoryChangeContinuationsByUser[userId] ?? [:]
            continuationsForUser[streamId] = continuation
            categoryChangeContinuationsByUser[userId] = continuationsForUser

            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.categoryChangeContinuationsByUser[userId]?[streamId] = nil
                    if self?.categoryChangeContinuationsByUser[userId]?.isEmpty == true {
                        self?.categoryChangeContinuationsByUser[userId] = nil
                    }
                }
            }

            Task { @MainActor [weak self] in
                guard let self else { return }
                await self.ensureRestored(userId: userId)
                self.emitCategoryChanges(for: userId)
            }
        }
    }

    func restoreState(for userId: UUID) async -> RestoreState {
        restoreStatesByUser[userId] ?? .notStarted
    }

    func ensureRestored(userId: UUID) async {
        guard await restoreState(for: userId) != .restored else { return }
        await restore(userId: userId)
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
            let userIds = Set(categories.map(\.userId))
            userIds.forEach { emitCategoryChanges(for: $0) }
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
            emitCategoryChanges(for: category.userId)
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
            emitCategoryChanges(for: userId)
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
            emitCategoryChanges(for: userId)
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
            emitCategoryChanges(for: previousCategory.userId)
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
            emitCategoryChanges(for: deletedCategory.userId)
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
    
    func restore(userId: UUID) async {
        restoreStatesByUser[userId] = .restoring

        do {
            _ = try fetchAllStoredCategories(userId: userId)
            restoreStatesByUser[userId] = .restored
            emitCategoryChanges(for: userId)
            logger.info("Restored local categories for user \(userId.uuidString)")
        } catch {
            restoreStatesByUser[userId] = .failed
            logger.error("Failed to restore local categories for user \(userId.uuidString)")
        }
    }

    func emitCategoryChanges(for userId: UUID) {
        let categories = (try? getAll(userId: userId)) ?? []
        categoryChangeContinuationsByUser[userId]?.values.forEach { $0.yield(categories) }
    }
}

//
//  CategoryStoreLocalTests.swift
//  StudyTests
//

import Testing
import SwiftData
import Foundation
@testable import Study

@MainActor
@Suite("CategoryStoreLocal", .serialized)
struct CategoryStoreLocalTests {
    private let userA = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    private let userB = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!

    @Test("fetches only categories for the requested user")
    func fetchesScopedCategories() throws {
        let store = try makeStore()
        let categoryA = makeCategory(id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!, userId: userA, name: "Math")
        let categoryB = makeCategory(id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!, userId: userB, name: "History")

        try store.saveAll([categoryA, categoryB])

        #expect(try store.getAll(userId: userA) == [categoryA])
        #expect(try store.getAll(userId: userB) == [categoryB])
    }

    @Test("does not return another user's category by id")
    func getByIdIsScopedByUser() throws {
        let store = try makeStore()
        let category = makeCategory(id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!, userId: userA, name: "Physics")

        try store.save(category)

        #expect(try store.getById(category.categoryId, userId: userA) == category)
        #expect(try store.getById(category.categoryId, userId: userB) == nil)
    }

    @Test("restore state becomes restored after restore")
    func restoreStateBecomesRestored() async throws {
        let store = try makeStore()

        #expect(await store.restoreState(for: userA) == .notStarted)

        await store.ensureRestored(userId: userA)

        #expect(await store.restoreState(for: userA) == .restored)
    }

    private func makeStore() throws -> CategoryStoreLocal {
        let container = StudyApp.makeContainer()
        try clearStoredCategories(from: container.mainContext)
        return CategoryStoreLocal(context: container.mainContext)
    }

    private func clearStoredCategories(from context: ModelContext) throws {
        let categories = try context.fetch(FetchDescriptor<StoredStudyCategory>())
        for category in categories {
            context.delete(category)
        }
        try context.save()
    }

    private func makeCategory(id: UUID, userId: UUID, name: String) -> StudyCategory {
        StudyCategory(
            categoryId: id,
            userId: userId,
            name: name,
            createdAt: "2026-06-25T12:00:00Z"
        )
    }
}

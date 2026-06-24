//
//  CategoryLocalStoreServiceProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol CategoryLocalStoreServiceProtocol {
    func getAll() async throws(CategoryLocalStoreError) -> [StudyCategory]
    func getById(_ id: UUID) async throws(CategoryLocalStoreError) -> StudyCategory?
    func saveAll(_ categories: [StudyCategory]) async throws(CategoryLocalStoreError)
    func save(_ category: StudyCategory) async throws(CategoryLocalStoreError)
    func delete(id: UUID) async throws(CategoryLocalStoreError)
    func rollbackCreate(id: UUID) async throws(CategoryLocalStoreError)
    func rollbackUpdate(previousCategory: StudyCategory) async throws(CategoryLocalStoreError)
    func rollbackDelete(deletedCategory: StudyCategory) async throws(CategoryLocalStoreError)
}

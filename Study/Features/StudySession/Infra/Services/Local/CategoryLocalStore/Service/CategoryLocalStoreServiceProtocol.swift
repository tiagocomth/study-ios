//
//  CategoryLocalStoreServiceProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol CategoryLocalStoreServiceProtocol {
    func getAll() throws(CategoryLocalStoreError) -> [StudyCategory]
    func getById(_ id: UUID) throws(CategoryLocalStoreError) -> StudyCategory?
    func saveAll(_ categories: [StudyCategory]) throws(CategoryLocalStoreError)
    func save(_ category: StudyCategory) throws(CategoryLocalStoreError)
    func delete(id: UUID) throws(CategoryLocalStoreError)
    func rollbackCreate(id: UUID) throws(CategoryLocalStoreError)
    func rollbackUpdate(previousCategory: StudyCategory) throws(CategoryLocalStoreError)
    func rollbackDelete(deletedCategory: StudyCategory) throws(CategoryLocalStoreError)
}

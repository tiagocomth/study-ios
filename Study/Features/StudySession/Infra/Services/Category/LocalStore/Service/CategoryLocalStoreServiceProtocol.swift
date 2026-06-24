//
//  CategoryLocalStoreServiceProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol CategoryLocalStoreServiceProtocol {
    func getAll() throws(CategoryLocalStoreError) -> [StudyCategory]
    func getById(_ id: UUID) throws(CategoryLocalStoreError) -> StudyCategory?
    func upsert(_ category: StudyCategory) throws(CategoryLocalStoreError)
    func upsert(_ categories: [StudyCategory]) throws(CategoryLocalStoreError)
    func delete(id: UUID) throws(CategoryLocalStoreError)
    func replaceAll(with categories: [StudyCategory]) throws(CategoryLocalStoreError)
}

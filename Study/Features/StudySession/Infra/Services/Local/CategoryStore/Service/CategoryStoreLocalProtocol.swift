//
//  CategoryStoreLocalProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol CategoryStoreLocalProtocol {
    func getAll() throws(CategoryStoreLocalError) -> [StudyCategory]
    func getById(_ id: UUID) throws(CategoryStoreLocalError) -> StudyCategory?
    func saveAll(_ categories: [StudyCategory]) throws(CategoryStoreLocalError)
    func save(_ category: StudyCategory) throws(CategoryStoreLocalError)
    func delete(id: UUID) throws(CategoryStoreLocalError)
    func rollbackCreate(id: UUID) throws(CategoryStoreLocalError)
    func rollbackUpdate(previousCategory: StudyCategory) throws(CategoryStoreLocalError)
    func rollbackDelete(deletedCategory: StudyCategory) throws(CategoryStoreLocalError)
}

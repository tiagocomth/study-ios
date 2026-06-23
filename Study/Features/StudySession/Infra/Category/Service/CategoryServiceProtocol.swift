//
//  CategoryServiceProtocol.swift
//  Study
//

import Foundation

nonisolated protocol CategoryServiceProtocol {
    func getAll() async throws(NetworkError) -> [StudyCategory]
    func getById(_ id: String) async throws(NetworkError) -> StudyCategory
    func create(_ dto: CreateCategoryDTO) async throws(NetworkError) -> StudyCategory
    func update(id: String, dto: UpdateCategoryDTO) async throws(NetworkError) -> StudyCategory
    func delete(id: String) async throws(NetworkError)
}

//
//  CategoryServiceProtocol.swift
//  Study
//

import Foundation

nonisolated protocol CategoryServiceProtocol {
    func getAll() async throws(NetworkError) -> [StudyCategory]
    func getById(_ id: UUID) async throws(NetworkError) -> StudyCategory
    func create(_ dto: CreateCategoryDTO) async throws(NetworkError) -> StudyCategory
    func update(id: UUID, dto: UpdateCategoryDTO) async throws(NetworkError) -> StudyCategory
    func delete(id: UUID) async throws(NetworkError)
}

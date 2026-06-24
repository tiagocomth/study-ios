//
//  CategoryRemoteProtocol.swift
//  Study
//

import Foundation

nonisolated protocol CategoryRemoteProtocol {
    func getAll() async throws(NetworkError) -> [StudyCategory]
    func getById(_ id: UUID) async throws(NetworkError) -> StudyCategory
    func create(_ dto: CreateCategoryDTO) async throws(NetworkError)
    func update(id: UUID, dto: UpdateCategoryDTO) async throws(NetworkError)
    func delete(id: UUID) async throws(NetworkError)
}

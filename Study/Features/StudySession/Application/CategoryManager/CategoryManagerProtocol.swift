//
//  CategoryManagerProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol CategoryManagerProtocol {
    func categoryChanges() -> AsyncStream<[StudyCategory]>
    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory]
    
    func create(_ dto: CreateCategoryDTO) throws -> StudyCategory
    func update(id: UUID, dto: UpdateCategoryDTO) throws -> StudyCategory
    func delete(id: UUID) throws
}

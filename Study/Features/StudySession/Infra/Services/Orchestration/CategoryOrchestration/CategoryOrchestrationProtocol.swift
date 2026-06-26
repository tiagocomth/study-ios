//
//  CategoryOrchestrationProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol CategoryOrchestrationProtocol {
    func categoryChanges() -> AsyncStream<[StudyCategory]>
    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory]
    
    func create(
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory
    
    func update(
        id: UUID,
        dto: UpdateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory
    
    func delete(
        id: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) throws
}

//
//  CategoryService.swift
//  Study
//

import Foundation

final class CategoryService: CategoryServiceProtocol {
    private let apiClient: APIClientProtocol
    private let logger: DomainLogging

    init(
        apiClient: APIClientProtocol,
        logger: DomainLogging = CategoryLogger()
    ) {
        self.apiClient = apiClient
        self.logger = logger
    }

    func getAll() async throws(NetworkError) -> [StudyCategory] {
        logger.info("Fetching categories")
        return try await apiClient.request(StudySessionEndpoint.getCategories)
    }

    func getById(_ id: String) async throws(NetworkError) -> StudyCategory {
        logger.info("Fetching category \(id)")
        return try await apiClient.request(StudySessionEndpoint.getCategoryById(id))
    }

    func create(_ dto: CreateCategoryDTO) async throws(NetworkError) -> StudyCategory {
        logger.info("Creating category")
        return try await apiClient.request(StudySessionEndpoint.createCategory(dto))
    }

    func update(id: String, dto: UpdateCategoryDTO) async throws(NetworkError) -> StudyCategory {
        logger.info("Updating category \(id)")
        return try await apiClient.request(StudySessionEndpoint.updateCategory(id: id, dto: dto))
    }

    func delete(id: String) async throws(NetworkError) {
        logger.info("Deleting category \(id)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.deleteCategory(id))
    }
}

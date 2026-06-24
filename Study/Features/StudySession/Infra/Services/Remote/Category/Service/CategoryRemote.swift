//
//  CategoryRemote.swift
//  Study
//

import Foundation

final class CategoryRemote: CategoryRemoteProtocol {
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

    func getById(_ id: UUID) async throws(NetworkError) -> StudyCategory {
        logger.info("Fetching category \(id.uuidString)")
        return try await apiClient.request(StudySessionEndpoint.getCategoryById(id))
    }

    func create(_ dto: CreateCategoryDTO) async throws(NetworkError) {
        logger.info("Creating category")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.createCategory(dto))
    }

    func update(id: UUID, dto: UpdateCategoryDTO) async throws(NetworkError) {
        logger.info("Updating category \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.updateCategory(id: id, dto: dto))
    }

    func delete(id: UUID) async throws(NetworkError) {
        logger.info("Deleting category \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.deleteCategory(id))
    }
}

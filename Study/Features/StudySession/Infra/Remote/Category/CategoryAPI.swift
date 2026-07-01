//
//  CategoryAPI.swift
//  Study
//

import Foundation

final class CategoryAPI: CategoryAPIProtocol {
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
        logger.info("Sending categories fetch request")
        return try await apiClient.request(StudySessionEndpoint.getCategories)
    }

    func getById(_ id: UUID) async throws(NetworkError) -> StudyCategory {
        logger.info("Sending category fetch request \(id.uuidString)")
        return try await apiClient.request(StudySessionEndpoint.getCategoryById(id))
    }

    func create(_ dto: CreateCategoryDTO) async throws(NetworkError) {
        logger.info("Sending category create request")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.createCategory(dto))
    }

    func update(id: UUID, dto: UpdateCategoryDTO) async throws(NetworkError) {
        logger.info("Sending category update request \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.updateCategory(id: id, dto: dto))
    }

    func delete(id: UUID) async throws(NetworkError) {
        logger.info("Sending category delete request \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.deleteCategory(id))
    }
}

//
//  ExploreGroupsService.swift
//  Study
//

import Foundation

protocol ExploreGroupsServiceProtocol {
    /// Busca grupos. Sem `filter` usa a listagem paginada (`GET /groups/all`);
    /// com `filter` usa a busca (`GET /groups/search`). `isPrivate` filtra por
    /// privacidade (nil = todos, false = públicos, true = privados).
    func fetchGroups(filter: String?, isPrivate: Bool?, page: Int) async throws(NetworkError) -> GroupsPage
}

final class ExploreGroupsService: ExploreGroupsServiceProtocol {
    private let apiClient: APIClientProtocol

    /// Itens por página (a API aceita no máximo 50).
    private let pageLimit = 20

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchGroups(filter: String?, isPrivate: Bool?, page: Int) async throws(NetworkError) -> GroupsPage {
        let endpoint: GroupEndpoint
        if let filter, !filter.isEmpty {
            endpoint = .search(query: filter, page: page, limit: pageLimit, isPrivate: isPrivate)
        } else {
            endpoint = .all(page: page, limit: pageLimit, isPrivate: isPrivate)
        }

        let response: PaginatedGroupsResponseDTO = try await apiClient.request(endpoint)
        return GroupsPage(groups: response.data.map { $0.toDomain() }, total: response.total)
    }
}

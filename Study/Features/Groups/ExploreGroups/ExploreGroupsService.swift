//
//  ExploreGroupsService.swift
//  Study
//

import Foundation

/// Uma página de grupos vinda do backend, com o total para a paginação.
struct GroupsPage {
    let groups: [StudyGroup]
    let total: Int
}

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
        let endpoint: ExploreGroupsEndpoint
        if let filter, !filter.isEmpty {
            endpoint = .search(query: filter, page: page, limit: pageLimit, isPrivate: isPrivate)
        } else {
            endpoint = .all(page: page, limit: pageLimit, isPrivate: isPrivate)
        }

        let response: PaginatedGroupsResponse = try await apiClient.request(endpoint)
        return GroupsPage(groups: response.data.map { $0.toDomain() }, total: response.total)
    }
}

extension ExploreGroupsService {
    /// Espelha `PaginatedGroupsResponseDto`.
    private struct PaginatedGroupsResponse: Decodable {
        let total: Int
        let data: [GroupDTO]
    }

    private enum ExploreGroupsEndpoint: Endpoint {
        case all(page: Int, limit: Int, isPrivate: Bool?)
        case search(query: String, page: Int, limit: Int, isPrivate: Bool?)

        var path: String {
            switch self {
            case .all:
                "/groups/all"
            case .search:
                "/groups/search"
            }
        }

        var method: HTTPMethod {
            .get
        }

        var task: HTTPTask {
            switch self {
            case let .all(page, limit, isPrivate):
                var params: Parameters = ["page": page, "limit": limit]
                if let isPrivate { params["isPrivate"] = isPrivate }
                return .requestURLParameters(params)
            case let .search(query, page, limit, isPrivate):
                // A API espera o termo na chave `q` (rejeita `query`).
                var params: Parameters = ["q": query, "page": page, "limit": limit]
                if let isPrivate { params["isPrivate"] = isPrivate }
                return .requestURLParameters(params)
            }
        }

        var headers: Headers? {
            nil
        }
    }
}

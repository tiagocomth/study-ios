//
//  GroupEndpoint.swift
//  Study
//
//  Endpoint único da feature de grupos (padrão: um enum de endpoint por feature,
//  igual ao `AuthEndpoint`).
//

import Foundation

enum GroupEndpoint: Endpoint {
    case create(CreateGroupRequestDTO)
    case all(page: Int, limit: Int, isPrivate: Bool?)
    case search(query: String, page: Int, limit: Int, isPrivate: Bool?)

    var path: String {
        switch self {
        case .create: "/groups"
        case .all: "/groups/all"
        case .search: "/groups/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .create: .post
        case .all, .search: .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .create(let request):
            return .requestJSONBody(request)
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

    var headers: Headers? { nil }
}

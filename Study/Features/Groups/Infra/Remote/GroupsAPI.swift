//
//  GroupsAPI.swift
//  Study
//

import Foundation

enum GroupsAPI: Endpoint {
    case myGroups

    var path: String {
        switch self {
        case .myGroups:
            return "/groups/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .myGroups:
            return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .myGroups:
            return .requestPlain
        }
    }

    var headers: Headers? {
        return ["Content-Type": "application/json"]
    }
}

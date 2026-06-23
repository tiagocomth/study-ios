//
//  StudySessionEndpoint.swift
//  Study
//

import Foundation

enum StudySessionEndpoint: Endpoint {
    case getCategories
    case getCategoryById(String)
    case createCategory(CreateCategoryDTO)
    case updateCategory(id: String, dto: UpdateCategoryDTO)
    case deleteCategory(String)

    var baseURL: String {
        "study-app-production-b3da.up.railway.app"
    }

    var path: String {
        switch self {
        case .getCategories, .createCategory:
            "/categories"
        case .getCategoryById(let id), .deleteCategory(let id):
            "/categories/\(id)"
        case .updateCategory(let id, _):
            "/categories/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getCategories, .getCategoryById:
            .get
        case .createCategory:
            .post
        case .updateCategory:
            .patch
        case .deleteCategory:
            .delete
        }
    }

    var task: HTTPTask {
        switch self {
        case .getCategories, .getCategoryById, .deleteCategory:
            .requestPlain
        case .createCategory(let dto):
            .requestJSONBody(dto)
        case .updateCategory(_, let dto):
            .requestJSONBody(dto)
        }
    }

    var headers: Headers? {
        nil
    }
}

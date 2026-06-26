//
//  StudySessionEndpoint.swift
//  Study
//

import Foundation

enum StudySessionEndpoint: Endpoint {
    case getStudySessions
    case startStudySession(StartStudySessionDTO)
    case pauseStudySession(id: UUID, dto: PauseStudySessionDTO)
    case resumeStudySession(id: UUID, dto: ResumeStudySessionDTO)
    case endStudySession(id: UUID, dto: EndStudySessionDTO)
    case deleteStudySession(UUID)

    case getCategories
    case getCategoryById(UUID)
    case createCategory(CreateCategoryDTO)
    case updateCategory(id: UUID, dto: UpdateCategoryDTO)
    case deleteCategory(UUID)

    var path: String {
        switch self {
        case .getStudySessions:
            "/sessions"
        case .startStudySession:
            "/sessions/start"
        case .pauseStudySession(let id, _):
            "/sessions/\(id.uuidString)/pause"
        case .resumeStudySession(let id, _):
            "/sessions/\(id.uuidString)/resume"
        case .endStudySession(let id, _):
            "/sessions/\(id.uuidString)/end"
        case .deleteStudySession(let id):
            "/sessions/\(id.uuidString)"
        case .getCategories, .createCategory:
            "/categories"
        case .getCategoryById(let id), .deleteCategory(let id):
            "/categories/\(id.uuidString)"
        case .updateCategory(let id, _):
            "/categories/\(id.uuidString)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getStudySessions, .getCategories, .getCategoryById:
            .get
        case .startStudySession, .pauseStudySession, .createCategory:
            .post
        case .resumeStudySession, .endStudySession, .updateCategory:
            .patch
        case .deleteStudySession, .deleteCategory:
            .delete
        }
    }

    var task: HTTPTask {
        switch self {
        case .getStudySessions, .getCategories, .getCategoryById, .deleteStudySession, .deleteCategory:
            .requestPlain
        case .startStudySession(let dto):
            .requestJSONBody(dto)
        case .pauseStudySession(_, let dto):
            .requestJSONBody(dto)
        case .resumeStudySession(_, let dto):
            .requestJSONBody(dto)
        case .endStudySession(_, let dto):
            .requestJSONBody(dto)
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

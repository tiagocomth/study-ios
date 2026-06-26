//
//  ProfileEndpoint.swift
//  Study
//
//  Created by Breno Marques on 23/06/26.
//

import Foundation

enum ProfileEndpoint: Endpoint {
    case updateProfile(UpdateProfileRequest)
    case getProfile(id: String)
    case getSessions

    var path: String {
        switch self {
        case .updateProfile:
            return "/users/me"
        case .getProfile(let id):
            return "/users/\(id)"
        case .getSessions:
            return "/users/me/sessions"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .updateProfile: .patch
        case .getProfile, .getSessions: .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .updateProfile(let request):
            return .requestJSONBody(request)
        case .getProfile:
            return .requestPlain
        case .getSessions:
            return .requestPlain
        }
    }

    var headers: Headers? {
        return nil
    }
}



//
//  NewPasswordService.swift
//  Study
//

import Foundation

protocol NewPasswordServiceProtocol {
    func updatePassword(_ password: Password, session: String) async throws(NetworkError)
}

final class NewPasswordService: NewPasswordServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func updatePassword(_ password: Password, session: String) async throws(NetworkError) {
        let endpoint = NewPasswordEndpoint.updatePassword(
            NewPasswordRequest(password: password.value, session: session)
        )
        let _: EmptyResponse = try await apiClient.request(endpoint)
    }
}

extension NewPasswordService {
    private struct NewPasswordRequest: Encodable {
        let password: String
        let session: String
    }

    private enum NewPasswordEndpoint: Endpoint {
        case updatePassword(NewPasswordRequest)

        var path: String {
            switch self {
            case .updatePassword:
                // TODO: Replace with the real new-password path.
                "/auth/forgot-password/new-password"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .updatePassword:
                // TODO: Replace with the real new-password http method.
                .post
            }
        }

        var task: HTTPTask {
            switch self {
            case .updatePassword(let request):
                .requestJSONBody(request)
            }
        }

        var headers: Headers? {
            nil
        }
    }
}

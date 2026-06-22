//
//  ForgetPasswordService.swift
//  Study
//

import Foundation

protocol ForgetPasswordServiceProtocol {
    func requestPasswordReset(email: Email) async throws(NetworkError)
}

final class ForgetPasswordService: ForgetPasswordServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func requestPasswordReset(email: Email) async throws(NetworkError) {
        let endpoint = ForgetPasswordEndpoint.requestPasswordReset(
            ForgetPasswordRequest(email: email.value)
        )
        let _: EmptyResponse = try await apiClient.request(endpoint)
    }
}

extension ForgetPasswordService {
    private struct ForgetPasswordRequest: Encodable {
        let email: String
    }

    private enum ForgetPasswordEndpoint: Endpoint {
        case requestPasswordReset(ForgetPasswordRequest)

        var path: String {
            switch self {
            case .requestPasswordReset:
                // TODO: Replace with the real forgot-password path.
                "/auth/forgot-password"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .requestPasswordReset:
                // TODO: Replace with the real forgot-password http method.
                .post
            }
        }

        var task: HTTPTask {
            switch self {
            case .requestPasswordReset(let request):
                .requestJSONBody(request)
            }
        }

        var headers: Headers? {
            nil
        }
    }
}

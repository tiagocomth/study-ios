//
//  CodeService.swift
//  Study
//

import Foundation

protocol CodeServiceProtocol {
    func validatePasswordResetCode(_ code: String) async throws(NetworkError) -> String
}

final class CodeService: CodeServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func validatePasswordResetCode(_ code: String) async throws(NetworkError) -> String {
        let endpoint = CodeEndpoint.validatePasswordResetCode(
            CodeValidationRequest(code: code)
        )
        let response: CodeValidationResponse = try await apiClient.request(endpoint)
        return response.session
    }
}

extension CodeService {
    private struct CodeValidationRequest: Encodable {
        let code: String
    }

    private struct CodeValidationResponse: Decodable {
        let session: String
    }

    private enum CodeEndpoint: Endpoint {
        case validatePasswordResetCode(CodeValidationRequest)

        var path: String {
            switch self {
            case .validatePasswordResetCode:
                // TODO: Replace with the real code validation path.
                "/auth/forgot-password/code"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .validatePasswordResetCode:
                // TODO: Replace with the real code validation http method.
                .post
            }
        }

        var task: HTTPTask {
            switch self {
            case .validatePasswordResetCode(let request):
                .requestJSONBody(request)
            }
        }

        var headers: Headers? {
            nil
        }
    }
}

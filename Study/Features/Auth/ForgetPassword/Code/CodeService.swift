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
        let endpoint = AuthEndpoint.validatePasswordResetCode(
            ValidateResetCodeRequestDTO(code: code)
        )
        let response: ValidateResetCodeResponseDTO = try await apiClient.request(endpoint)
        return response.otp
    }
}

//
//  CodeService.swift
//  Study
//

import Foundation

protocol CodeServiceProtocol {
    func validatePasswordResetCode(email: String, code: String) async throws(NetworkError) -> String
}

final class CodeService: CodeServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func validatePasswordResetCode(email: String, code: String) async throws(NetworkError) -> String {
        let endpoint = AuthEndpoint.validatePasswordResetCode(
            ValidateResetCodeRequestDTO(email: email, otp: code)
        )
        let response: ValidateResetCodeResponseDTO = try await apiClient.request(endpoint)
        return response.resetToken
    }
}

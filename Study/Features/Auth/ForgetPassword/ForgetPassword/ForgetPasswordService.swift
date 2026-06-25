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
        let endpoint = AuthEndpoint.requestPasswordReset(
            ForgotPasswordRequestDTO(email: email.value)
        )
        let _: EmptyResponse = try await apiClient.request(endpoint)
    }
}

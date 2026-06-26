//
//  NewPasswordService.swift
//  Study
//

import Foundation

protocol NewPasswordServiceProtocol {
    func updatePassword(_ password: Password, otp: String) async throws(NetworkError)
}

final class NewPasswordService: NewPasswordServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func updatePassword(_ password: Password, otp: String) async throws(NetworkError) {
        let endpoint = AuthEndpoint.updatePassword(
            NewPasswordRequestDTO(password: password.value)
        )
        // O OTP vai como bearer token desta chamada (não no corpo).
        let _: EmptyResponse = try await apiClient.request(endpoint, token: otp)
    }
}

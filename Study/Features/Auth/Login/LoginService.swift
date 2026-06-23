//
//  LoginService.swift
//  Study
//

import Foundation

protocol LoginServiceProtocol {
    func login(email: Email, password: Password) async throws(NetworkError) -> AuthResponse
}

final class LoginService: LoginServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func login(email: Email, password: Password) async throws(NetworkError) -> AuthResponse {
        let dto = LoginRequestDTO(email: email.value, password: password.value)
        let response: AuthResponseDTO = try await apiClient.request(AuthEndpoint.login(dto))
        return response.toDomain()
    }
}

//
//  RegisterService.swift
//  Study
//

import Foundation

protocol RegisterServiceProtocol {
    /// Cria o cadastro pendente e dispara o envio do código de validação para o e-mail.
    func register(name: String, email: Email, password: Password) async throws(NetworkError)
}

final class RegisterService: RegisterServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func register(name: String, email: Email, password: Password) async throws(NetworkError) {
        // A API de cadastro espera name + email + senha (`RegisterDto`).
        let dto = RegisterRequestDTO(name: name, email: email.value, password: password.value)
        // POST /auth/register devolve apenas `{ message }` (201) e dispara o envio do
        // código por e-mail. A sessão só é iniciada na etapa de validação (verify).
        let _: EmptyResponse = try await apiClient.request(AuthEndpoint.register(dto))
    }
}

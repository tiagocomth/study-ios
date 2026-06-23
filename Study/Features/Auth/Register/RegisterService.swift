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
        // A API de cadastro aceita apenas email + senha.
        // TODO: `name` ainda não é enviado — quando necessário, gravar via PATCH /users/me.
        let dto = RegisterRequestDTO(email: email.value, password: password.value)
        // O endpoint devolve `{ accessToken, user }` (loga direto), mas aqui a sessão
        // só é iniciada na etapa de validação de e-mail (verify), então o token é descartado.
        let _: AuthResponseDTO = try await apiClient.request(AuthEndpoint.register(dto))
    }
}

//
//  EmailValidationService.swift
//  Study
//

import Foundation

protocol EmailValidationServiceProtocol {
    /// Confirma o código recebido por e-mail. Em caso de sucesso o usuário é
    /// criado/ativado no backend e a resposta traz os dados para iniciar a sessão.
    func validate(email: Email, code: String) async throws -> AuthResponse
    /// Reenvia o código de validação para o e-mail informado.
    func resendCode(email: Email) async throws
}

final class EmailValidationService: EmailValidationServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func validate(email: Email, code: String) async throws -> AuthResponse {
        // POST /auth/register/verify — confirma o OTP e devolve `{ accessToken, user }`.
        let dto = VerifyEmailValidationRequestDTO(email: email.value, otp: code)
        let response: AuthResponseDTO = try await apiClient.request(AuthEndpoint.verifyEmailValidation(dto))
        return response.toDomain()
    }

    func resendCode(email: Email) async throws {
        // O código é enviado pelo próprio POST /auth/register; o backend ainda não
        // expõe um endpoint dedicado de reenvio. Quando expuser, ligar aqui.
    }
}

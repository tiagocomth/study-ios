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
        // STUB: o endpoint de validação de e-mail ainda não existe no backend.
        // Quando subir (padrão do forgot-password/verify, devolvendo `{ accessToken, user }`),
        // basta remover o stub e descomentar:
        //
        // let dto = VerifyEmailValidationRequestDTO(email: email.value, otp: code)
        // let response: AuthResponseDTO = try await apiClient.request(AuthEndpoint.verifyEmailValidation(dto))
        // return response.toDomain()
        return AuthResponse(
            user: User(id: UUID().uuidString, name: email.value, photo: nil, individualHoursTotal: 0, groupHoursTotal: 0),
            token: "mock-token"
        )
    }

    func resendCode(email: Email) async throws {
        // STUB: o endpoint de envio do código ainda não existe no backend.
        // Quando subir (padrão do forgot-password, body `{ email }`), descomentar:
        //
        // let dto = SendEmailValidationRequestDTO(email: email.value)
        // let _: EmptyResponse = try await apiClient.request(AuthEndpoint.sendEmailValidation(dto))
    }
}

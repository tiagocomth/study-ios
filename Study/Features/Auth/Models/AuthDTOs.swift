//
//  AuthDTOs.swift
//  Study
//
//  DTOs de request/response da API de autenticação e o mapeamento para o
//  domínio (`AuthResponse`/`User`).
//

import Foundation

// MARK: - Requests

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct RegisterRequestDTO: Encodable {
    let email: String
    let password: String
}

/// Dispara o envio do código de validação de e-mail.
/// Segue o padrão do `forgot-password` (body só com o e-mail).
struct SendEmailValidationRequestDTO: Encodable {
    let email: String
}

/// Confirma o código de validação de e-mail.
/// Segue o padrão do `forgot-password/verify` (`email` + `otp`).
struct VerifyEmailValidationRequestDTO: Encodable {
    let email: String
    let otp: String
}

// MARK: - Requests (recuperação de senha)

struct ForgotPasswordRequestDTO: Encodable {
    let email: String
}

struct ValidateResetCodeRequestDTO: Encodable {
    let code: String
}

/// O OTP (token de reset) viaja como bearer token, então o body leva só a senha.
struct NewPasswordRequestDTO: Encodable {
    let password: String
}

// MARK: - Responses

/// `UserResponseDto` da API — hoje traz apenas `id` e `email`.
struct AuthUserDTO: Decodable {
    let id: String
    let email: String
}

/// `LoginResponseDto` / `RegisterResponseDto` — token + usuário.
struct AuthResponseDTO: Decodable {
    let accessToken: String
    let user: AuthUserDTO
}

/// Resposta da validação do código de reset — devolve o OTP usado nas próximas chamadas.
struct ValidateResetCodeResponseDTO: Decodable {
    let otp: String
}

// MARK: - Mapeamento para o domínio

extension AuthUserDTO {
    /// Monta a entidade `User` a partir do que a API devolve. Como o backend só
    /// retorna `id`/`email`, os demais campos recebem defaults.
    /// - Parameter name: nome a usar; quando `nil`, cai no e-mail como placeholder.
    func toUser(name: String? = nil) -> User {
        User(
            id: id,
            name: name ?? email,
            photo: nil,
            individualHoursTotal: 0,
            groupHoursTotal: 0
        )
    }
}

extension AuthResponseDTO {
    func toDomain(name: String? = nil) -> AuthResponse {
        AuthResponse(user: user.toUser(name: name), token: accessToken)
    }
}

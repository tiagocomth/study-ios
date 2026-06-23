//
//  AuthEndpoint.swift
//  Study
//
//  Endpoint único da feature de autenticação (padrão: um enum de endpoint por feature).
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login(LoginRequestDTO)
    case register(RegisterRequestDTO)

    // Validação de e-mail: os endpoints ainda não existem no backend. Modelados
    // no padrão do `forgot-password` — quando subirem, basta ajustar o `path`.
    case sendEmailValidation(SendEmailValidationRequestDTO)
    case verifyEmailValidation(VerifyEmailValidationRequestDTO)

    // Recuperação de senha.
    case requestPasswordReset(ForgotPasswordRequestDTO)
    case validatePasswordResetCode(ValidateResetCodeRequestDTO)
    case updatePassword(NewPasswordRequestDTO)

    var path: String {
        switch self {
        case .login: "/auth/login"
        case .register: "/auth/register"
        case .sendEmailValidation: "/auth/verify-email"            // TODO: confirmar path real
        case .verifyEmailValidation: "/auth/verify-email/verify"   // TODO: confirmar path real
        case .requestPasswordReset: "/auth/forgot-password"
        case .validatePasswordResetCode: "/auth/forgot-password/code"        // TODO: confirmar path real
        case .updatePassword: "/auth/forgot-password/new-password"           // TODO: confirmar path real
        }
    }

    var method: HTTPMethod { .post }

    var task: HTTPTask {
        switch self {
        case .login(let dto): .requestJSONBody(dto)
        case .register(let dto): .requestJSONBody(dto)
        case .sendEmailValidation(let dto): .requestJSONBody(dto)
        case .verifyEmailValidation(let dto): .requestJSONBody(dto)
        case .requestPasswordReset(let dto): .requestJSONBody(dto)
        case .validatePasswordResetCode(let dto): .requestJSONBody(dto)
        case .updatePassword(let dto): .requestJSONBody(dto)
        }
    }

    var headers: Headers? { nil }
}

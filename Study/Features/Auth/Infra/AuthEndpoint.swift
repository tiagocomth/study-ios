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

    // Validação de e-mail do cadastro: o código é enviado pelo próprio `register`
    // e confirmado aqui, que devolve `{ accessToken, user }` e loga o usuário.
    case verifyEmailValidation(VerifyEmailValidationRequestDTO)

    // Recuperação de senha.
    case requestPasswordReset(ForgotPasswordRequestDTO)
    case validatePasswordResetCode(ValidateResetCodeRequestDTO)
    case updatePassword(NewPasswordRequestDTO)

    var path: String {
        switch self {
        case .login: "/auth/login"
        case .register: "/auth/register"
        case .verifyEmailValidation: "/auth/register/verify"
        case .requestPasswordReset: "/auth/forgot-password"
        case .validatePasswordResetCode: "/auth/forgot-password/verify"        // TODO: confirmar path real
        case .updatePassword: "/auth/forgot-password/reset"           // TODO: confirmar path real
        }
    }

    var method: HTTPMethod { .post }

    var task: HTTPTask {
        switch self {
        case .login(let dto): .requestJSONBody(dto)
        case .register(let dto): .requestJSONBody(dto)
        case .verifyEmailValidation(let dto): .requestJSONBody(dto)
        case .requestPasswordReset(let dto): .requestJSONBody(dto)
        case .validatePasswordResetCode(let dto): .requestJSONBody(dto)
        case .updatePassword(let dto): .requestJSONBody(dto)
        }
    }

    var headers: Headers? { nil }
}

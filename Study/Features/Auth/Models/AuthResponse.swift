//
//  AuthResponse.swift
//  Study
//

import Foundation

/// Resposta de um fluxo de autenticação bem-sucedido (login ou validação de e-mail).
/// É o que o endpoint deve devolver para que o `UserSessionService` consiga iniciar a sessão.
struct AuthResponse: Decodable {
    let user: User
    let token: String
}

//
//  LoginWorker.swift
//  Study
//

import Foundation

protocol LoginWorkerProtocol {
    /// Regra que habilita o login a partir do que está preenchido na tela.
    func canLogin(email: String, password: String) -> Bool
    /// Valida as entradas, autentica e inicia a sessão.
    func login(email: Email, password: Password) async throws
}

final class LoginWorker: LoginWorkerProtocol {
    private let service: LoginServiceProtocol
    private let session: UserSessionProtocol

    init(service: LoginServiceProtocol, session: UserSessionProtocol) {
        self.service = service
        self.session = session
    }

    func canLogin(email: String, password: String) -> Bool {
        Email(value: email).isValid() && Password(value: password).isValid()
    }

    func login(email: Email, password: Password) async throws {
        guard email.isValid() else {
            throw LoginWorkerError.invalidEmail
        }
        guard password.isValid() else {
            throw LoginWorkerError.invalidPassword
        }

        let response = try await service.login(email: email, password: password)
        // Sessão é iniciada aqui (regra de negócio fora do ViewModel). O root do
        // app observa o `UserSessionService` e troca para a tela principal.
        await session.startSession(user: response.user, token: response.token)
    }
}

enum LoginWorkerError: LocalizedError {
    case invalidEmail
    case invalidPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email."
        case .invalidPassword:
            return "Password must be at least 8 characters."
        }
    }
}

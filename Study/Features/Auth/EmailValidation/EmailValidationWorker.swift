//
//  EmailValidationWorker.swift
//  Study
//

import Foundation

protocol EmailValidationWorkerProtocol {
    /// Regra que habilita o botão de validar (código completo e válido).
    func isCodeValid(_ code: String) -> Bool
    /// Valida o código, confirma no backend e inicia a sessão.
    func validate(email: Email, code: String) async throws
    func resendCode(email: Email) async throws
}

final class EmailValidationWorker: EmailValidationWorkerProtocol {
    private let service: EmailValidationServiceProtocol
    private let session: UserSessionProtocol

    init(service: EmailValidationServiceProtocol, session: UserSessionProtocol) {
        self.service = service
        self.session = session
    }

    func isCodeValid(_ code: String) -> Bool {
        PasswordResetCode(value: code).isValid()
    }

    func validate(email: Email, code: String) async throws {
        guard email.isValid() else {
            throw EmailValidationWorkerError.invalidEmail
        }
        let resetCode = PasswordResetCode(value: code)
        guard resetCode.isValid() else {
            throw EmailValidationWorkerError.invalidCode
        }

        let response = try await service.validate(email: email, code: resetCode)
        // Sessão é iniciada aqui (regra de negócio fora do ViewModel). O root do
        // app observa o `UserSessionService` e troca para a tela principal.
        session.startSession(user: response.user, token: response.token)
    }

    func resendCode(email: Email) async throws {
        try await service.resendCode(email: email)
    }
}

enum EmailValidationWorkerError: LocalizedError {
    case invalidEmail
    case invalidCode

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email."
        case .invalidCode:
            return "O código deve ter \(PasswordResetCode.length) dígitos."
        }
    }
}

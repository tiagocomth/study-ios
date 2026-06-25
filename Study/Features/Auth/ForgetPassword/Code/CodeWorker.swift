//
//  CodeWorker.swift
//  Study
//

import Foundation

protocol CodeWorkerProtocol {
    /// Regra que habilita a validação a partir do código preenchido na tela.
    func canValidate(_ code: PasswordResetCode) -> Bool
    func validatePasswordResetCode(_ code: PasswordResetCode) async throws
}

final class CodeWorker: CodeWorkerProtocol {
    private let service: CodeServiceProtocol
    private let sessionStore: PasswordResetSessionStore

    init(service: CodeServiceProtocol, sessionStore: PasswordResetSessionStore) {
        self.service = service
        self.sessionStore = sessionStore
    }

    func canValidate(_ code: PasswordResetCode) -> Bool {
        code.isValid()
    }

    func validatePasswordResetCode(_ code: PasswordResetCode) async throws {
        guard code.isValid() else {
            throw CodeWorkerError.invalidCode
        }

        let otp = try await service.validatePasswordResetCode(code.value)
        sessionStore.save(otp)
    }
}

enum CodeWorkerError: LocalizedError {
    case invalidCode

    var errorDescription: String? {
        switch self {
        case .invalidCode:
            return "Invalid code."
        }
    }
}

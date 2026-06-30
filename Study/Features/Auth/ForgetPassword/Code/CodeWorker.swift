//
//  CodeWorker.swift
//  Study
//

import Foundation

protocol CodeWorkerProtocol {
    func validatePasswordResetCode(email: Email, code: PasswordResetCode) async throws
}

final class CodeWorker: CodeWorkerProtocol {
    private let service: CodeServiceProtocol
    private let sessionStore: PasswordResetSessionStore

    init(service: CodeServiceProtocol, sessionStore: PasswordResetSessionStore) {
        self.service = service
        self.sessionStore = sessionStore
    }

    func validatePasswordResetCode(email: Email, code: PasswordResetCode) async throws {
        guard code.isValid(), email.isValid() else {
            throw CodeWorkerError.invalidCode
        }

        let resetToken = try await service.validatePasswordResetCode(email: email.value, code: code.value)
        sessionStore.save(resetToken)
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

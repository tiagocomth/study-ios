//
//  CodeWorker.swift
//  Study
//

import Foundation

protocol CodeWorkerProtocol {
    func validatePasswordResetCode(_ code: PasswordResetCode) async throws
}

final class CodeWorker: CodeWorkerProtocol {
    private let service: CodeServiceProtocol
    private let sessionStore: PasswordResetSessionStore

    init(service: CodeServiceProtocol, sessionStore: PasswordResetSessionStore) {
        self.service = service
        self.sessionStore = sessionStore
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

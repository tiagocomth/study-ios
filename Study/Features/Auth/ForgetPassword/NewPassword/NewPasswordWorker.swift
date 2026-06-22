//
//  NewPasswordWorker.swift
//  Study
//

import Foundation

protocol NewPasswordWorkerProtocol {
    func updatePassword(_ password: Password, confirmation: Password) async throws
}

final class NewPasswordWorker: NewPasswordWorkerProtocol {
    private let service: NewPasswordServiceProtocol
    private let sessionStore: PasswordResetSessionStore

    init(service: NewPasswordServiceProtocol, sessionStore: PasswordResetSessionStore) {
        self.service = service
        self.sessionStore = sessionStore
    }

    func updatePassword(_ password: Password, confirmation: Password) async throws {
        guard password.isValid() else {
            throw NewPasswordWorkerError.invalidPassword
        }

        guard password == confirmation else {
            throw NewPasswordWorkerError.passwordsDoNotMatch
        }

        guard let session = sessionStore.session else {
            throw NewPasswordWorkerError.missingSession
        }

        try await service.updatePassword(password, session: session)
        sessionStore.clear()
    }
}

enum NewPasswordWorkerError: LocalizedError {
    case invalidPassword
    case passwordsDoNotMatch
    case missingSession

    var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "Invalid password."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        case .missingSession:
            return "Password reset session is missing."
        }
    }
}

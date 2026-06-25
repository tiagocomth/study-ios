//
//  RegisterWorker.swift
//  Study
//

import Foundation

protocol RegisterWorkerProtocol {
    /// Regra que habilita o cadastro a partir do que está preenchido na tela.
    func canRegister(name: String, email: String, password: String, confirmation: String) -> Bool
    func register(name: String, email: Email, password: Password, confirmation: Password) async throws
}

final class RegisterWorker: RegisterWorkerProtocol {
    private let service: RegisterServiceProtocol

    init(service: RegisterServiceProtocol) {
        self.service = service
    }

    func canRegister(name: String, email: String, password: String, confirmation: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Email(value: email).isValid() &&
        Password(value: password).isValid() &&
        Password(value: password) == Password(value: confirmation)
    }

    func register(name: String, email: Email, password: Password, confirmation: Password) async throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RegisterWorkerError.missingName
        }
        guard email.isValid() else {
            throw RegisterWorkerError.invalidEmail
        }
        guard password.isValid() else {
            throw RegisterWorkerError.invalidPassword
        }
        guard password == confirmation else {
            throw RegisterWorkerError.passwordsDoNotMatch
        }

        try await service.register(name: name, email: email, password: password)
    }
}

enum RegisterWorkerError: LocalizedError {
    case missingName
    case invalidEmail
    case invalidPassword
    case passwordsDoNotMatch

    var errorDescription: String? {
        switch self {
        case .missingName:
            return "Name is required."
        case .invalidEmail:
            return "Invalid email."
        case .invalidPassword:
            return "Password must be at least 8 characters."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        }
    }
}

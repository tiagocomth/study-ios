//
//  LoginWorker.swift
//  Study
//

import Foundation

protocol LoginWorkerProtocol {
    func login(email: Email, password: Password) async throws -> AuthResponse
}

final class LoginWorker: LoginWorkerProtocol {
    private let service: LoginServiceProtocol

    init(service: LoginServiceProtocol) {
        self.service = service
    }

    func login(email: Email, password: Password) async throws -> AuthResponse {
        guard email.isValid() else {
            throw LoginWorkerError.invalidEmail
        }
        guard !password.value.isEmpty else {
            throw LoginWorkerError.missingPassword
        }

        return try await service.login(email: email, password: password)
    }
}

enum LoginWorkerError: LocalizedError {
    case invalidEmail
    case missingPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email."
        case .missingPassword:
            return "Password is required."
        }
    }
}

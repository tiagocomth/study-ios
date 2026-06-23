//
//  EmailValidationWorker.swift
//  Study
//

import Foundation

protocol EmailValidationWorkerProtocol {
    func validate(email: Email, code: String) async throws -> AuthResponse
    func resendCode(email: Email) async throws
}

final class EmailValidationWorker: EmailValidationWorkerProtocol {
    private let service: EmailValidationServiceProtocol

    init(service: EmailValidationServiceProtocol) {
        self.service = service
    }

    func validate(email: Email, code: String) async throws -> AuthResponse {
        guard email.isValid() else {
            throw EmailValidationWorkerError.invalidEmail
        }
        return try await service.validate(email: email, code: code)
    }

    func resendCode(email: Email) async throws {
        try await service.resendCode(email: email)
    }
}

enum EmailValidationWorkerError: LocalizedError {
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email."
        }
    }
}

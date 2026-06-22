//
//  ForgetPasswordWorker.swift
//  Study
//

import Foundation

protocol ForgetPasswordWorkerProtocol {
    func requestPasswordReset(email: String) async throws
}

final class ForgetPasswordWorker: ForgetPasswordWorkerProtocol {
    private let service: ForgetPasswordServiceProtocol

    init(service: ForgetPasswordServiceProtocol) {
        self.service = service
    }

    func requestPasswordReset(email: String) async throws {
        let email = Email(value: email)

        guard email.isValid() else {
            throw ForgetPasswordWorkerError.invalidEmail
        }

        try await service.requestPasswordReset(email: email)
    }
}

enum ForgetPasswordWorkerError: LocalizedError {
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email."
        }
    }
}

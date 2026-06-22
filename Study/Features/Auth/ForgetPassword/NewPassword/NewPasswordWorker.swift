//
//  NewPasswordWorker.swift
//  Study
//

import Foundation

protocol NewPasswordWorkerProtocol {
}

final class NewPasswordWorker: NewPasswordWorkerProtocol {
    private let service: NewPasswordServiceProtocol
    private let sessionStore: PasswordResetSessionStore

    init(service: NewPasswordServiceProtocol, sessionStore: PasswordResetSessionStore) {
        self.service = service
        self.sessionStore = sessionStore
    }

    // TODO: usar `passwordResetSession` para chamar o service quando o endpoint de nova senha existir.
    private var passwordResetSession: String? {
        sessionStore.session
    }
}

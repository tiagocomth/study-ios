//
//  PasswordResetSessionStore.swift
//  Study
//

import Foundation

/// Guarda o OTP (token de reset) entre as telas do fluxo de recuperação de senha.
final class PasswordResetSessionStore {
    private(set) var otp: String?

    func save(_ otp: String) {
        self.otp = otp
    }

    func clear() {
        otp = nil
    }
}

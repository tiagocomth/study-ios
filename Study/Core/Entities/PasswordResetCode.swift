//
//  PasswordResetCode.swift
//  Study
//

import Foundation

struct PasswordResetCode: Equatable {
    /// Quantidade de dígitos do código (OTP de 6 dígitos).
    static let length = 6

    var value: String

    init(value: String = "") {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func isValid() -> Bool {
        value.count == Self.length && value.allSatisfy(\.isNumber)
    }
}

//
//  PasswordResetCode.swift
//  Study
//

import Foundation

struct PasswordResetCode: Equatable {
    var value: String

    init(value: String = "") {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func isValid() -> Bool {
        value.count == 6 && value.allSatisfy(\.isNumber)
    }
}

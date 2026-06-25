//
//  Email.swift
//  Study
//

import Foundation

struct Email: Hashable {
    var value: String

    init(value: String = "") {
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func isValid() -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}

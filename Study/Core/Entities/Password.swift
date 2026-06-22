//
//  Password.swift
//  Study
//

import Foundation

struct Password: Equatable {
    var value: String

    init(value: String = "") {
        self.value = value
    }

    func isValid() -> Bool {
        value.count >= 8
    }
}

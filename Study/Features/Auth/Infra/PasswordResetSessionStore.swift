//
//  PasswordResetSessionStore.swift
//  Study
//

import Foundation

final class PasswordResetSessionStore {
    private(set) var session: String?

    func save(_ session: String) {
        self.session = session
    }

    func clear() {
        session = nil
    }
}

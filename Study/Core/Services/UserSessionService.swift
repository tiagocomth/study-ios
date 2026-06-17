//
//  UserSessionService.swift
//  Study
//

import Foundation
import Combine
import os

/// Single source of truth for the logged-in user.
/// Conform to this protocol when a type only needs to read/act on the session
/// (keeps call sites testable). SwiftUI views that need to *observe* changes
/// should depend on the concrete `UserSessionService` (an `ObservableObject`).
@MainActor
protocol UserSessionProtocol: AnyObject {
    var currentUser: User? { get }
    var token: String? { get }
    var isLoggedIn: Bool { get }

    func restore()
    func startSession(user: User, token: String)
    func update(user: User)
    func logout()
}

@MainActor
final class UserSessionService: ObservableObject, UserSessionProtocol {

    static let shared = UserSessionService()

    // MARK: - Published state
    @Published private(set) var currentUser: User?

    // MARK: - Dependencies
    private static let userKey = "study_session_user"
    private static let tokenKey = "study_auth_token"

    // `nonisolated` so the `init` (and thus the `shared` singleton) can run in a
    // nonisolated context. Both are immutable and thread-safe.
    nonisolated private let keychain: KeychainServicing
    nonisolated private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Study", category: "UserSession")

    // MARK: - Init
    /// `nonisolated` so the `shared` singleton can be created from the static
    /// initializer's nonisolated context. `currentUser` starts `nil`; call
    /// `restore()` at app launch to load any persisted session.
    nonisolated init(keychain: KeychainServicing = KeychainService()) {
        self.keychain = keychain
    }

    // MARK: - Data providers
    var token: String? {
        keychain.readString(for: Self.tokenKey)
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    // MARK: - Actions
    /// Loads any persisted session into memory. Call once at app launch.
    func restore() {
        currentUser = keychain.read(User.self, for: Self.userKey)
    }

    func startSession(user: User, token: String) {
        do {
            try keychain.saveString(token, for: Self.tokenKey)
        } catch {
            logger.error("Failed to save auth token: \(error.localizedDescription, privacy: .public)")
        }
        persist(user)
    }

    func update(user: User) {
        persist(user)
    }

    func logout() {
        do {
            try keychain.delete(for: Self.userKey)
            try keychain.delete(for: Self.tokenKey)
        } catch {
            logger.error("Failed to clear session from keychain: \(error.localizedDescription, privacy: .public)")
        }
        currentUser = nil
    }

    // MARK: - Private
    /// Single write path: persists the user and only then publishes the change,
    /// so storage and in-memory state never diverge.
    private func persist(_ user: User) {
        do {
            try keychain.save(user, for: Self.userKey)
            currentUser = user
        } catch {
            logger.error("Failed to persist user session: \(error.localizedDescription, privacy: .public)")
        }
    }
}

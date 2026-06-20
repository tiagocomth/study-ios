//
//  AuthenticationInterceptor.swift
//  Study
//
//  Created by Thiago de Jesus on 18/06/26.
//

import Foundation

/// Reacts to authentication failures (HTTP 401) detected by the network layer.
///
/// The network layer only *detects* the 401 and notifies the interceptor; the
/// actual reaction (logging out, routing to the login screen) is configured by
/// the app via `configure(onUnauthorized:)`. This keeps `Core/Network` free of
/// any dependency on the session/auth feature.
protocol AuthenticationInterceptorProtocol: AnyObject, Sendable {
    /// Called by the client when a request fails with `401 Unauthorized`.
    func handleUnauthorized()
}

/// Global interceptor for authentication errors.
///
/// Configure it once at app launch:
/// ```swift
/// AuthenticationInterceptor.shared.configure {
///     UserSessionService.shared.logout()
///     // route back to login…
/// }
/// ```
final class AuthenticationInterceptor: AuthenticationInterceptorProtocol, @unchecked Sendable {

    static let shared = AuthenticationInterceptor()

    private let lock = NSLock()
    private var onUnauthorized: (() -> Void)?

    private init() {}

    /// Registers the action to run whenever a `401` is detected.
    /// - Parameter onUnauthorized: Executed on every unauthorized response
    ///   (e.g. clear the session and present the login flow).
    func configure(onUnauthorized: @escaping () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        self.onUnauthorized = onUnauthorized
    }

    func handleUnauthorized() {
        lock.lock()
        let callback = onUnauthorized
        lock.unlock()
        callback?()
    }
}

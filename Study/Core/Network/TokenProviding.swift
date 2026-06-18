//
//  TokenProviding.swift
//  Study
//
//  Created by Thiago de Jesus on 18/06/26.
//

import Foundation

/// Supplies the bearer token used to authenticate outgoing requests.
///
/// Keeping this as a small abstraction (instead of depending on the session
/// service directly) lets the network layer stay decoupled from where the
/// token actually lives, and makes the `APIClient` trivial to test with a stub.
protocol TokenProviding: Sendable {
    /// The current auth token, or `nil` when the user is not authenticated.
    var token: String? { get }
}

/// Closure-backed provider, so any token source (session service, keychain,
/// a test stub) can be plugged in without conforming a dedicated type.
struct TokenProvider: TokenProviding {
    private let resolve: @Sendable () -> String?

    init(_ resolve: @escaping @Sendable () -> String?) {
        self.resolve = resolve
    }

    var token: String? { resolve() }
}

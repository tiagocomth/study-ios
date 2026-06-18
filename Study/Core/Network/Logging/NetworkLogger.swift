//
//  NetworkLogger.swift
//  Study
//
//  Created by Thiago de Jesus on 18/06/26.
//

import Foundation

/// Logs outgoing requests and their outcomes.
///
/// Exposed as a protocol so the `APIClient` can be tested without noise: pass a
/// no-op conforming type (or `nil`) to silence logging in unit tests.
protocol NetworkLogging: Sendable {
    /// Logs a request just before it is sent.
    func logRequest(_ request: URLRequest)
    /// Logs a completed response (any status code).
    func logResponse(_ response: HTTPURLResponse, data: Data, for request: URLRequest)
    /// Logs a transport-level or unexpected failure.
    func logFailure(_ error: Error, for request: URLRequest)
}

/// `DomainLogger`-backed implementation (category `"Networking"`), reusing the
/// shared `os.Logger` setup and its `info`/`error` methods. Messages are logged
/// as `.public` (by `DomainLogger`) so they show in Console.app during
/// development; consider gating verbose payloads to `DEBUG` if they may contain
/// sensitive data.
final class NetworkLogger: DomainLogger, NetworkLogging, @unchecked Sendable {

    init() {
        super.init(category: "Networking")
    }

    func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "invalid URL"
        let bodySize = request.httpBody?.count ?? 0
        let body = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "nil"

        info("➡️ REQUEST \(method) \(url)\nBODY (\(bodySize) bytes): \(body)")
    }

    func logResponse(_ response: HTTPURLResponse, data: Data, for request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = response.url?.absoluteString ?? request.url?.absoluteString ?? "invalid URL"
        let body = String(data: data, encoding: .utf8) ?? "<non-string data>"
        let symbol = (200...299).contains(response.statusCode) ? "✅" : "⚠️"

        info("\(symbol) RESPONSE \(response.statusCode) \(method) \(url)\nDATA (\(data.count) bytes): \(body)")
    }

    func logFailure(_ error: Error, for request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "invalid URL"

        // `self.error(_:)` is the inherited log method; `error` is the parameter.
        self.error("❌ FAILURE \(method) \(url)\nERROR: \(String(describing: error))")
    }
}

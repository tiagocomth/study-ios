//
//  NetworkLogger.swift
//  Study
//
//  Created by Thiago de Jesus on 18/06/26.
//

import Foundation
import os

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

/// `os.Logger`-backed implementation. Bodies are logged as `.public` so they are
/// visible in Console.app during development; consider gating verbose output to
/// `DEBUG` builds if request/response payloads contain sensitive data.
struct NetworkLogger: NetworkLogging {

    private let logger: Logger

    init(category: String = "Networking") {
        let subsystem = Bundle.main.bundleIdentifier ?? "Study"
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "invalid URL"
        let bodySize = request.httpBody?.count ?? 0
        let body = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "nil"

        logger.info("➡️ REQUEST \(method, privacy: .public) \(url, privacy: .public)\nBODY (\(bodySize) bytes): \(body, privacy: .public)")
    }

    func logResponse(_ response: HTTPURLResponse, data: Data, for request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = response.url?.absoluteString ?? request.url?.absoluteString ?? "invalid URL"
        let body = String(data: data, encoding: .utf8) ?? "<non-string data>"
        let symbol = (200...299).contains(response.statusCode) ? "✅" : "⚠️"

        logger.info("\(symbol, privacy: .public) RESPONSE \(response.statusCode, privacy: .public) \(method, privacy: .public) \(url, privacy: .public)\nDATA (\(data.count) bytes): \(body, privacy: .public)")
    }

    func logFailure(_ error: Error, for request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "invalid URL"

        logger.error("❌ FAILURE \(method, privacy: .public) \(url, privacy: .public)\nERROR: \(String(describing: error), privacy: .public)")
    }
}

//
//  Loggers.swift
//  Study
//

import Foundation
import os

/// Abstraction over a domain logger so call sites can inject a fake in tests.
nonisolated protocol DomainLogging: Sendable {
    func debug(_ message: String)
    func info(_ message: String)
    func error(_ message: String)
}

/// Base class that wraps an `os.Logger` for a single domain (category).
/// Subclass per domain so each one can be injected and defaulted with `.init()`.
nonisolated class DomainLogger: DomainLogging, @unchecked Sendable {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Study"

    private let logger: Logger

    init(category: String) {
        self.logger = Logger(subsystem: Self.subsystem, category: category)
    }

    func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}

// MARK: - Domain loggers

final class SessionLogger: DomainLogger, @unchecked Sendable {
    init() { super.init(category: "Session") }
}

final class AuthLogger: DomainLogger, @unchecked Sendable {
    init() { super.init(category: "Auth") }
}

final class PaymentLogger: DomainLogger, @unchecked Sendable {
    init() { super.init(category: "Payment") }
}

final class CategoryLogger: DomainLogger, @unchecked Sendable {
    init() { super.init(category: "Category") }
}

final class StudySessionTrackerLogger: DomainLogger, @unchecked Sendable {
    init() { super.init(category: "StudySessionTracker") }
}

final class OfflineOperationQueueLogger: DomainLogger, @unchecked Sendable {
    init() { super.init(category: "OfflineOperationQueue") }
}

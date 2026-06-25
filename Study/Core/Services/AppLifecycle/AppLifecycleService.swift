//
//  AppLifecycleService.swift
//  Study
//

import SwiftUI

@MainActor
final class AppLifecycleService: AppLifecycleServiceProtocol {
    private let logger: DomainLogging
    private var continuations: [UUID: AsyncStream<AppLifecycleState>.Continuation]
    private var currentState: AppLifecycleState?

    init(logger: DomainLogging = AppLifecycleLogger()) {
        self.logger = logger
        self.continuations = [:]
        self.currentState = nil
    }

    var stateChanges: AsyncStream<AppLifecycleState> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            let id = UUID()
            continuations[id] = continuation

            if let currentState {
                continuation.yield(currentState)
            }

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.continuations[id] = nil
                }
            }
        }
    }

    func updateState(_ state: AppLifecycleState) {
        guard currentState != state else { return }
        currentState = state

        continuations.values.forEach { $0.yield(state) }
        logger.info("App lifecycle state changed to \(String(describing: state))")
    }
}

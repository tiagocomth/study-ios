//
//  ConnectivityMonitorService.swift
//  Study
//

import Foundation
import Network

@MainActor
final class ConnectivityMonitorService: ConnectivityMonitorServiceProtocol {
    private let queue: DispatchQueue
    private let logger: DomainLogging
    private var monitor: NWPathMonitor?
    private var continuations: [UUID: AsyncStream<Bool>.Continuation]
    private var currentIsConnected: Bool

    init(
        queue: DispatchQueue = DispatchQueue(label: "study.connectivity.monitor"),
        logger: DomainLogging = ConnectivityLogger()
    ) {
        self.queue = queue
        self.logger = logger
        self.monitor = nil
        self.continuations = [:]
        self.currentIsConnected = false
    }

    var isConnected: Bool {
        get async { currentIsConnected }
    }

    var connectivityChanges: AsyncStream<Bool> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            let id = UUID()
            continuations[id] = continuation
            continuation.yield(currentIsConnected)

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.continuations[id] = nil
                }
            }
        }
    }

    func start() {
        guard monitor == nil else { return }

        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied

            Task { @MainActor [weak self] in
                self?.updateConnectionStatus(isConnected)
            }
        }

        self.monitor = monitor
        monitor.start(queue: queue)
        logger.info("Started connectivity monitor")
    }

    func stop() {
        guard let monitor else { return }

        monitor.cancel()
        self.monitor = nil
        logger.info("Stopped connectivity monitor")
    }
}

private extension ConnectivityMonitorService {
    func updateConnectionStatus(_ isConnected: Bool) {
        guard currentIsConnected != isConnected else { return }

        currentIsConnected = isConnected
        continuations.values.forEach { $0.yield(isConnected) }

        if isConnected {
            logger.info("Connectivity restored")
        } else {
            logger.info("Connectivity lost")
        }
    }
}

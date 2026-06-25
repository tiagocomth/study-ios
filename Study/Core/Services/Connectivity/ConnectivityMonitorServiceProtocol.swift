//
//  ConnectivityMonitorServiceProtocol.swift
//  Study
//

import Foundation

@MainActor
protocol ConnectivityMonitorServiceProtocol: AnyObject {
    var isConnected: Bool { get async }
    var connectivityChanges: AsyncStream<Bool> { get }

    func start()
    func stop()
}

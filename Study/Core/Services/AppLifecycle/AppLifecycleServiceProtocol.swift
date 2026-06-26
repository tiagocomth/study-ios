//
//  AppLifecycleServiceProtocol.swift
//  Study
//

import SwiftUI

@MainActor
protocol AppLifecycleServiceProtocol: AnyObject {
    var stateChanges: AsyncStream<AppLifecycleState> { get }

    func updateState(_ state: AppLifecycleState)
}

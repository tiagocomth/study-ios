//
//  AppLifecycleState.swift
//  Study
//

import SwiftUI

enum AppLifecycleState: Equatable, Sendable {
    case active
    case inactive
    case background
    case unknown
    
    init(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            self = .active
        case .inactive:
            self = .inactive
        case .background:
            self = .background
        @unknown default:
            self = .inactive
        }
    }
}

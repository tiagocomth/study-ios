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
    
    static func make(scenePhase: ScenePhase) -> Self {
        switch scenePhase {
        case .active: return .active
        case .inactive: return .inactive
        case .background: return .background
        @unknown default: return .unknown
        }
    }
}

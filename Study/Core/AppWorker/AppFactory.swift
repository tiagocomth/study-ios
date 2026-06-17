//
//  AppFactory.swift
//  Study
//

import SwiftUI

final class AppFactory {
    
    private var authCoordinator: AuthCoordinator?
    
    func makeAuthCoordinator() -> AuthCoordinator {
        guard let authCoordinator else {
            self.authCoordinator = AuthCoordinator(factory: .init())
            return self.authCoordinator!
        }
        
        return authCoordinator
    }

}

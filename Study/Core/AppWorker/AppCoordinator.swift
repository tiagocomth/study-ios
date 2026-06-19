//
//  AppCoordinator.swift
//  Study
//

import SwiftUI

final class AppCoordinator { // MARK: Ter o estado se está logado ou não
    
    private var authCoordinator: AuthCoordinator?
    
    
    func makeAuthCoordinator() -> AuthCoordinator {
        guard let authCoordinator else {
            self.authCoordinator = AuthCoordinator(factory: .init())
            return self.authCoordinator!
        }
        
        return authCoordinator
    }
}

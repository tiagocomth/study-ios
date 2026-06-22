//
//  AppCoordinator.swift
//  Study
//

import SwiftUI

final class AppCoordinator {
    
    private var authCoordinator: AuthCoordinator?
    
    func makeAuthCoordinator(apiClient: APIClientProtocol) -> AuthCoordinator {
        guard let authCoordinator else {
            self.authCoordinator = AuthCoordinator(factory: .init(apiClient: apiClient))
            return self.authCoordinator!
        }
        
        return authCoordinator
    }
}

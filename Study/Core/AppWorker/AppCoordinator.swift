//
//  AppCoordinator.swift
//  Study
//

import SwiftUI

final class AppCoordinator {
    
    private var authCoordinator: AuthCoordinator?
    func makeAuthCoordinator(apiClient: APIClientProtocol, session: UserSessionProtocol) -> AuthCoordinator {
        guard let authCoordinator else {
            let coordinator = AuthCoordinator(factory: .init(apiClient: apiClient, session: session))
            self.authCoordinator = coordinator
            return coordinator
        }

        return authCoordinator
    }
}

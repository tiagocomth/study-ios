//
//  AppCoordinator.swift
//  Study
//

import SwiftUI

final class AppCoordinator {

    private var authCoordinator: AuthCoordinator?
    private var groupCoordinator: GroupCoordinator?

    func makeAuthCoordinator(apiClient: APIClientProtocol, session: UserSessionProtocol) -> AuthCoordinator {
        guard let authCoordinator else {
            let coordinator = AuthCoordinator(factory: .init(apiClient: apiClient, session: session))
            self.authCoordinator = coordinator
            return coordinator
        }

        return authCoordinator
    }

    func makeGroupCoordinator(apiClient: APIClientProtocol) -> GroupCoordinator {
        guard let groupCoordinator else {
            self.groupCoordinator = GroupCoordinator(factory: .init(apiClient: apiClient))
            return self.groupCoordinator!
        }

        return groupCoordinator
    }
}

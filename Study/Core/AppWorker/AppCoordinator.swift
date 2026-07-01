//
//  AppCoordinator.swift
//  Study
//

import SwiftUI

final class AppCoordinator {
    
    private var authCoordinator: AuthCoordinator?
    private var studySessionCoordinator: StudySessionCoordinator?
    private var groupCoordinator: GroupCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    
    func makeAuthCoordinator(apiClient: APIClientProtocol, session: UserSessionProtocol) -> AuthCoordinator {
        guard let authCoordinator else {
            let coordinator = AuthCoordinator(factory: .init(apiClient: apiClient, session: session))
            self.authCoordinator = coordinator
            return coordinator
        }

        return authCoordinator
    }

    func makeStudySessionCoordinator(factory: StudySessionFactory) -> StudySessionCoordinator {
        guard let studySessionCoordinator else {
            let coordinator = StudySessionCoordinator(factory: factory)
            self.studySessionCoordinator = coordinator
            return coordinator
        }

        return studySessionCoordinator
    }
    func makeGroupCoordinator(factory: GroupFactory) -> GroupCoordinator {
        guard let groupCoordinator else {
            let coordinator = GroupCoordinator(factory: factory)
            self.groupCoordinator = coordinator
            return coordinator
        }
        return groupCoordinator
    }

    func makeProfileCoordinator(factory: ProfileFactory) -> ProfileCoordinator {
        guard let profileCoordinator else {
            let coordinator = ProfileCoordinator(factory: factory)
            self.profileCoordinator = coordinator
            return coordinator
        }
        return profileCoordinator
    }
}

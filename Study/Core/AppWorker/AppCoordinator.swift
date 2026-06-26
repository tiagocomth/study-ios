//
//  AppCoordinator.swift
//  Study
//

import SwiftUI

final class AppCoordinator {
    
    private var authCoordinator: AuthCoordinator?
    private var studySessionCoordinator: StudySessionCoordinator?
    
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
}

//
//  ProfileCoordinator.swift
//  Study
//

import SwiftUI

protocol ProfileCoordinatorProtocol: AnyObject {
    func presentPremium()
    func dismissPremium()
    func presentLogoutConfirmation()
    func dismissLogoutConfirmation()
    func presentEditProfile()
    func dismissEditProfile()
}

final class ProfileCoordinator: Coordinator {
    
    var navigationController: NavigationController = .init()
    private let factory: ProfileFactory

    init(factory: ProfileFactory) {
        self.factory = factory
        factory.profileCoordinator = self
    }

    var rootView: some View {
        factory.makeProfileView()
    }

    func coordinate(to route: ProfileRouter) -> some View {
        switch route {
        case .premium:
            factory.makePremiumView()
        case .logoutConfirmation:
            factory.makeLogoutConfirmationView()
        case .editProfile:
            factory.makeEditProfileView()
        }
    }
}

extension ProfileCoordinator: ProfileCoordinatorProtocol {
    
    func presentPremium() {
        navigationController.presentSheet(router: ProfileRouter.premium)
    }

    func dismissPremium() {
        navigationController.dismissSheet()
    }

    func presentLogoutConfirmation() {
        navigationController.presentSheet(router: ProfileRouter.logoutConfirmation)
    }

    func dismissLogoutConfirmation() {
        navigationController.dismissSheet()
    }

    func presentEditProfile() {
        navigationController.presentSheet(router: ProfileRouter.editProfile)
    }

    func dismissEditProfile() {
        navigationController.dismissSheet()
    }
}

extension ProfileCoordinator: PremiumCoordinatorProtocol {}
extension ProfileCoordinator: LogoutConfirmationCoordinatorProtocol {}
extension ProfileCoordinator: EditProfileCoordinatorProtocol {}

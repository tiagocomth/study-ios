//
//  AuthCoordinator.swift
//  Study
//

import SwiftUI

final class AuthCoordinator: Coordinator {
    
    var navigationController: NavigationController = .init()
    private let factory: AuthFactory

    init(factory: AuthFactory) {
        self.factory = factory
        factory.authCoordinator = self
    }
    
    var rootView: some View {
        factory.makeLoginView()
    }

    func coordinate(to route: AuthRouter) -> some View {
        switch route {
        case .forgotPassword:
            factory.makeForgetPasswordView()
        case .code:
            factory.makeCodeView()
        case .newPassword:
            factory.makeNewPasswordView()
        }
    }
    
    private func navigateTo(route: AuthRouter) {
        navigationController.push(router: route)
    }
    
    private func presentSheetTo(route: AuthRouter) {
        navigationController.presentSheet(router: route)
    }
    
    private func navigateBack() {
        navigationController.pop()
    }
    
    private func dismissSheet() {
        navigationController.dismissSheet()
    }
}

extension AuthCoordinator: LoginCoordinatorProtocol {
    
    func navigateToForgotPassword() {
        navigateTo(route: .forgotPassword)
    }
}

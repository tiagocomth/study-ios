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
        case .code(let email):
            factory.makeCodeView(email: email)
        case .newPassword:
            factory.makeNewPasswordView()
        case .register:
            factory.makeRegisterView()
        case .emailValidate(let email):
            factory.makeEmailValidateView(email: email)
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
    
    private func popToRoot() {
        navigationController.popToRoot()
    }

    private func dismissSheet() {
        navigationController.dismissSheet()
    }
}

extension AuthCoordinator: LoginCoordinatorProtocol {
    
    func navigateToRegister() {
        navigateTo(route: .register)
    }

    func navigateToForgotPassword() {
        navigateTo(route: .forgotPassword)
    }
}

extension AuthCoordinator: ForgetPasswordCoordinatorProtocol {

    func navigateToCode(email: Email) {
        navigateTo(route: .code(email: email))
    }
}

extension AuthCoordinator: CodeCoordinatorProtocol {

    func navigateToNewPassword() {
        navigateTo(route: .newPassword)
    }
}

extension AuthCoordinator: NewPasswordCoordinatorProtocol {

    func navigateBackToRoot() {
        popToRoot()
    }
}

extension AuthCoordinator: RegisterCoordinatorProtocol {
    func navigateToEmailValidate(email: Email) {
        navigateTo(route: .emailValidate(email: email))
    }
}


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
}

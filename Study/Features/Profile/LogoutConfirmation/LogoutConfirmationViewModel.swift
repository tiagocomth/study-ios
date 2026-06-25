//
//  LogoutConfirmationViewModel.swift
//  Study
//
//  Created by Breno Marques on 24/06/26.
//

import Foundation
import Combine

protocol LogoutConfirmationCoordinatorProtocol: AnyObject {
    func dismissLogoutConfirmation()
}

final class LogoutConfirmationViewModel: ObservableObject {
    
    weak var coordinator: LogoutConfirmationCoordinatorProtocol?
    private let userSession: UserSessionProtocol

    init(userSession: UserSessionProtocol) {
        self.userSession = userSession
    }

    func logout() {
        userSession.logout()
        coordinator?.dismissLogoutConfirmation()
    }

    func dismiss() {
        coordinator?.dismissLogoutConfirmation()
    }
}

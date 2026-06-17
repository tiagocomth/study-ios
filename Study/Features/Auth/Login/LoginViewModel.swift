//
//  LoginViewModel.swift
//  Study
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    weak var coordinator: LoginCoordinatorProtocol?
    private let worker: LoginWorkerProtocol

    init(worker: LoginWorkerProtocol) {
        self.worker = worker
    }

    func navigateToForgotPassword() {
        coordinator?.navigateToForgotPassword()
    }
}

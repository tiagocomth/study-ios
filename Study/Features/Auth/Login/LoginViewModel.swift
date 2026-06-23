//
//  LoginViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    weak var coordinator: LoginCoordinatorProtocol?
    private let worker: LoginWorkerProtocol
    private let session: UserSessionProtocol

    init(worker: LoginWorkerProtocol, session: UserSessionProtocol) {
        self.worker = worker
        self.session = session
    }

    var isFormValid: Bool {
        Email(value: email).isValid() && !password.isEmpty
    }

    func login() {
        guard isFormValid, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await worker.login(
                    email: Email(value: email),
                    password: Password(value: password)
                )
                // Sessão logada: o root do app observa o `UserSessionService`
                // e troca automaticamente para a tela principal.
                session.startSession(user: response.user, token: response.token)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func navigateToForgotPassword() {
        coordinator?.navigateToForgotPassword()
    }

    func navigateToRegister() {
        coordinator?.navigateToRegister()
    }
}

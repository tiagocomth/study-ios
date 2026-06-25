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

    init(worker: LoginWorkerProtocol) {
        self.worker = worker
    }

    /// Habilita o botão — regra definida pelo Worker.
    var isFormValid: Bool {
        worker.canLogin(email: email, password: password)
    }

    func login() {
        guard isFormValid, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // O Worker autentica e inicia a sessão; o root do app observa o
                // `UserSessionService` e troca automaticamente para a tela principal.
                try await worker.login(
                    email: Email(value: email),
                    password: Password(value: password)
                )
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

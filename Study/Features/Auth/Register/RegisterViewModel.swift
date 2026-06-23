//
//  RegisterViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    weak var coordinator: RegisterCoordinatorProtocol?
    private let worker: RegisterWorkerProtocol

    init(worker: RegisterWorkerProtocol) {
        self.worker = worker
    }

    var isFormValid: Bool {
        !name.isEmpty &&
        Email(value: email).isValid() &&
        Password(value: password).isValid() &&
        password == confirmPassword
    }

    func register() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await worker.register(
                    name: name,
                    email: Email(value: email),
                    password: Password(value: password),
                    confirmation: Password(value: confirmPassword)
                )
                coordinator?.navigateToEmailValidate(email: email)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

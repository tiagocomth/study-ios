//
//  NewPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class NewPasswordViewModel: ObservableObject {
    weak var coordinator: NewPasswordCoordinatorProtocol?
    private let worker: NewPasswordWorkerProtocol
    private var password = Password()
    private var passwordConfirmation = Password()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var passwordValue: String {
        get {
            password.value
        }
        set {
            updatePasswordValue(newValue)
        }
    }

    var passwordConfirmationValue: String {
        get {
            passwordConfirmation.value
        }
        set {
            updatePasswordConfirmationValue(newValue)
        }
    }

    var isFormValid: Bool {
        password.isValid() && passwordConfirmation.isValid() && password.value == passwordConfirmation.value
    }

    init(worker: NewPasswordWorkerProtocol) {
        self.worker = worker
    }

    func updatePassword() {
        guard !isLoading else { return }

        let password = password
        let passwordConfirmation = passwordConfirmation

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await worker.updatePassword(password, confirmation: passwordConfirmation)
                await MainActor.run {
                    isLoading = false
                    coordinator?.navigateBackToRoot()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updatePasswordValue(_ value: String) {
        objectWillChange.send()
        password = Password(value: value)
        errorMessage = nil
    }

    private func updatePasswordConfirmationValue(_ value: String) {
        objectWillChange.send()
        passwordConfirmation = Password(value: value)
        errorMessage = nil
    }
}

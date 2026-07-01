//
//  ForgetPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class ForgetPasswordViewModel: ObservableObject {
    weak var coordinator: ForgetPasswordCoordinatorProtocol?
    private let worker: ForgetPasswordWorkerProtocol
    private var email = Email()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var emailValue: String {
        get {
            email.value
        }
        set {
            updateEmailValue(newValue)
        }
    }

    var isFormValid: Bool {
        email.isValid()
    }

    init(worker: ForgetPasswordWorkerProtocol) {
        self.worker = worker
    }

    func recoverPassword() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await worker.requestPasswordReset(email: email)
                await MainActor.run {
                    isLoading = false
                    coordinator?.navigateToCode(email: email)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateEmailValue(_ value: String) {
        objectWillChange.send()
        email = Email(value: value)
        errorMessage = nil
    }
}

//
//  ForgetPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class ForgetPasswordViewModel: ObservableObject {
    weak var coordinator: ForgetPasswordCoordinatorProtocol?
    private let worker: ForgetPasswordWorkerProtocol
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

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
                    coordinator?.navigateToCode()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

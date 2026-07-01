//
//  CodeViewModel.swift
//  Study
//

import Foundation
import Combine

final class CodeViewModel: ObservableObject {
    let email: Email
    weak var coordinator: CodeCoordinatorProtocol?
    private let worker: CodeWorkerProtocol
    private var code = PasswordResetCode()
    @Published private(set) var canValidateCode: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var codeValue: String {
        get {
            code.value
        }
        set {
            updateCodeValue(newValue)
        }
    }

    init(email: Email, worker: CodeWorkerProtocol) {
        self.email = email
        self.worker = worker
    }

    func validateCode() {
        guard canValidateCode, !isLoading else { return }

        let code = code

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await worker.validatePasswordResetCode(email: email, code: code)
                await MainActor.run {
                    isLoading = false
                    coordinator?.navigateToNewPassword()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateCodeValue(_ value: String) {
        objectWillChange.send()
        let filtered = String(value.filter(\.isNumber).prefix(PasswordResetCode.length))
        code = PasswordResetCode(value: filtered)
        canValidateCode = code.isValid()
        errorMessage = nil
    }
}

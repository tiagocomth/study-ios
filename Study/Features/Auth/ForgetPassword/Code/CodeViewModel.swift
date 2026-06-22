//
//  CodeViewModel.swift
//  Study
//

import Foundation
import Combine

final class CodeViewModel: ObservableObject {
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

    init(worker: CodeWorkerProtocol) {
        self.worker = worker
    }

    func validateCode() {
        guard canValidateCode, !isLoading else { return }

        let code = code

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await worker.validatePasswordResetCode(code)
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
        code = PasswordResetCode(value: value)
        canValidateCode = code.isValid()
        errorMessage = nil
    }
}

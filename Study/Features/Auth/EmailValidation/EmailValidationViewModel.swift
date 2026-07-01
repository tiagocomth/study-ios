//
//  EmailValidationViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class EmailValidationViewModel: ObservableObject {
    /// Quantidade de dígitos esperada no código — regra na entidade `PasswordResetCode`.
    static var codeLength: Int { PasswordResetCode.length }

    @Published var code = "" {
        didSet {
            // Mantém apenas dígitos e limita ao tamanho esperado.
            let filtered = String(code.filter(\.isNumber).prefix(Self.codeLength))
            if filtered != code { code = filtered }
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?

    let email: Email
    weak var coordinator: EmailValidationCoordinatorProtocol?
    private let worker: EmailValidationWorkerProtocol

    init(email: Email, worker: EmailValidationWorkerProtocol) {
        self.email = email
        self.worker = worker
    }

    func navigateBack() {
        coordinator?.navigateBack()
    }

    /// Habilita o botão — regra (código válido) definida pelo Worker.
    var isCodeComplete: Bool {
        worker.isCodeValid(code)
    }

    func validate() {
        guard isCodeComplete, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // O Worker valida o código, confirma no backend e inicia a sessão.
                // O root do app observa o `UserSessionService` e troca de tela.
                try await worker.validate(email: email, code: code)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func resendCode() {
        guard !isLoading else { return }
        errorMessage = nil

        Task {
            do {
                try await worker.resendCode(email: email)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

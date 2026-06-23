//
//  EmailValidationViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class EmailValidationViewModel: ObservableObject {
    /// Quantidade de dígitos esperada no código de validação.
    static let codeLength = 5

    @Published var code = "" {
        didSet {
            // Mantém apenas dígitos e limita ao tamanho esperado.
            let filtered = String(code.filter(\.isNumber).prefix(Self.codeLength))
            if filtered != code { code = filtered }
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?

    let email: String
    private let worker: EmailValidationWorkerProtocol
    private let session: UserSessionProtocol

    init(email: String, worker: EmailValidationWorkerProtocol, session: UserSessionProtocol) {
        self.email = email
        self.worker = worker
        self.session = session
    }

    var isCodeComplete: Bool {
        code.count == Self.codeLength
    }

    func validate() {
        guard isCodeComplete, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await worker.validate(email: Email(value: email), code: code)
                // Código validado: cria/loga o usuário. O root do app observa o
                // `UserSessionService` e troca para a tela principal.
                session.startSession(user: response.user, token: response.token)
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
                try await worker.resendCode(email: Email(value: email))
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

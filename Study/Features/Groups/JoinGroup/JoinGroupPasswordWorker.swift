//
//  JoinGroupPasswordWorker.swift
//  Study
//

import Foundation

protocol JoinGroupPasswordWorkerProtocol {
    /// O grupo exige senha para entrar? (privado = exige).
    func requiresPassword(isPrivate: Bool) -> Bool

    /// Regra que habilita o botão "Entrar" a partir do preenchido na tela.
    func canJoin(isPrivate: Bool, password: String) -> Bool

    /// Valida as entradas e vincula o usuário ao grupo no backend.
    func join(groupId: String, isPrivate: Bool, password: String) async throws
}

final class JoinGroupPasswordWorker: JoinGroupPasswordWorkerProtocol {
    private let service: JoinGroupPasswordServiceProtocol

    init(service: JoinGroupPasswordServiceProtocol) {
        self.service = service
    }

    func requiresPassword(isPrivate: Bool) -> Bool {
        isPrivate
    }

    func canJoin(isPrivate: Bool, password: String) -> Bool {
        // Grupo público entra direto; privado precisa de senha não-vazia.
        guard requiresPassword(isPrivate: isPrivate) else { return true }
        return !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func join(groupId: String, isPrivate: Bool, password: String) async throws {
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        var finalPassword: String?
        if requiresPassword(isPrivate: isPrivate) {
            guard !trimmedPassword.isEmpty else {
                throw JoinGroupWorkerError.missingPassword
            }
            finalPassword = trimmedPassword
        }

        do {
            try await service.join(groupId: groupId, password: finalPassword)
        } catch let error as NetworkError {
            // Entrar é idempotente: se o backend diz que o usuário já é membro,
            // tratamos como sucesso e seguimos para a tela do grupo.
            guard Self.isAlreadyMember(error) else { throw error }
        }
    }

    /// O erro indica que o usuário já pertence ao grupo? A API responde `400`
    /// com a mensagem "Você já é membro deste grupo." (surfacada pela camada de
    /// rede). Casamos pela mensagem por falta de um código de erro dedicado.
    private static func isAlreadyMember(_ error: NetworkError) -> Bool {
        guard let message = error.errorDescription?.lowercased() else { return false }
        return message.contains("já é membro")
    }
}

enum JoinGroupWorkerError: LocalizedError {
    case missingPassword

    var errorDescription: String? {
        switch self {
        case .missingPassword:
            return "Informe a senha da sala para entrar."
        }
    }
}

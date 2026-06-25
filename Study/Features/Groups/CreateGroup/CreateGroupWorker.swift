//
//  CreateGroupWorker.swift
//  Study
//

import Foundation

protocol CreateGroupWorkerProtocol {
    /// Faixa de membros permitida (plano gratuito = até 10).
    var maxMembersRange: ClosedRange<Int> { get }

    /// Regra que habilita a criação a partir do que está preenchido na tela.
    func canCreate(name: String, isPrivate: Bool, password: String) -> Bool

    /// Valida, normaliza as entradas e cria o grupo no backend.
    func createGroup(name: String, description: String, isPrivate: Bool, password: String, maxMembers: Int) async throws -> StudyGroup
}

final class CreateGroupWorker: CreateGroupWorkerProtocol {
    private let service: CreateGroupServiceProtocol

    /// Limites de senha definidos pela API (`CreateGroupDto`).
    private let passwordRange = 4...60

    /// Plano gratuito é limitado a 10 membros pelo backend.
    let maxMembersRange = 2...10

    init(service: CreateGroupServiceProtocol) {
        self.service = service
    }

    func canCreate(name: String, isPrivate: Bool, password: String) -> Bool {
        let hasName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        // Grupo privado exige senha com pelo menos 4 caracteres.
        let hasValidPassword = !isPrivate || password.count >= 4
        return hasName && hasValidPassword
    }

    func createGroup(name: String, description: String, isPrivate: Bool, password: String, maxMembers: Int) async throws -> StudyGroup {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw CreateGroupWorkerError.emptyName
        }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = trimmedDescription.isEmpty ? nil : trimmedDescription

        // Grupo privado = grupo com senha (o backend deriva `isPrivate` daí).
        // Quando há senha, ela precisa ter de 4 a 60 caracteres (`CreateGroupDto`).
        var finalPassword: String?
        if isPrivate {
            guard passwordRange.contains(password.count) else {
                throw CreateGroupWorkerError.invalidPassword
            }
            finalPassword = password
        }

        // TODO: validar máximo de grupos e regras de premium.
        return try await service.createGroup(
            name: trimmedName,
            description: finalDescription,
            maxMembers: maxMembers,
            password: finalPassword
        )
    }
}

enum CreateGroupWorkerError: LocalizedError {
    case emptyName
    case invalidPassword

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Informe um nome para o grupo."
        case .invalidPassword:
            return "A senha deve ter entre 4 e 60 caracteres."
        }
    }
}

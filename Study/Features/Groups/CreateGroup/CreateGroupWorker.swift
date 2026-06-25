//
//  CreateGroupWorker.swift
//  Study
//

import Foundation

protocol CreateGroupWorkerProtocol {
    func createGroup(name: String, description: String?, maxMembers: Int?, password: String?) async throws -> StudyGroup
}

final class CreateGroupWorker: CreateGroupWorkerProtocol {
    private let service: CreateGroupServiceProtocol

    /// Limites de senha definidos pela API (`CreateGroupDto`).
    private let passwordRange = 4...60

    init(service: CreateGroupServiceProtocol) {
        self.service = service
    }

    func createGroup(name: String, description: String?, maxMembers: Int?, password: String?) async throws -> StudyGroup {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw CreateGroupWorkerError.emptyName
        }

        // `isPrivate` é derivado no backend pela presença de senha. Quando há senha,
        // ela precisa ter de 4 a 60 caracteres (`CreateGroupDto`).
        var finalPassword: String?
        if let password, !password.isEmpty {
            guard passwordRange.contains(password.count) else {
                throw CreateGroupWorkerError.invalidPassword
            }
            finalPassword = password
        }

        // TODO: validar máximo de grupos e regras de premium.
        return try await service.createGroup(
            name: trimmedName,
            description: description,
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

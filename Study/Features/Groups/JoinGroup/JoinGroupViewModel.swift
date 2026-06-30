//
//  JoinGroupViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class JoinGroupViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: JoinGroupPasswordWorkerProtocol
    let group: StudyGroup

    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dados reais do grupo (vindos do Explore)
    var groupName: String { group.name }
    var groupDescription: String? { group.description }
    var maxMembers: Int { group.maxMembers }

    /// Mostra o campo de senha? (privado = sim) — regra no Worker.
    var requiresPassword: Bool { worker.requiresPassword(isPrivate: group.isPrivate) }

    /// Habilita o botão "Entrar" — regra no Worker.
    var canJoin: Bool {
        worker.canJoin(isPrivate: group.isPrivate, password: password) && !isLoading
    }

    // MARK: - Mock (o payload do Explore ainda não traz estes campos)
    /// TODO: substituir por dados reais quando o backend expor contagem de membros.
    let currentMembersCount = 9
    /// TODO: substituir pelo nome do dono (resolver `group.ownerId`) quando houver endpoint.
    let administratorName = "Sofia Cutrim Cabral"

    init(group: StudyGroup, worker: JoinGroupPasswordWorkerProtocol) {
        self.group = group
        self.worker = worker
    }

    func join() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await worker.join(
                    groupId: group.id,
                    isPrivate: group.isPrivate,
                    password: password
                )
                isLoading = false
                // Fecha o pop-up e navega para a tela de membros do grupo.
                coordinator?.completeJoin(group: group)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func cancel() {
        coordinator?.dismissJoinGroup()
    }
}

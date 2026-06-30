//
//  CreateGroupViewModel.swift
//  Study
//

import Foundation
import Combine

final class CreateGroupViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: CreateGroupWorkerProtocol

    @Published var name = ""
    @Published var groupDescription = ""
    @Published var password = ""
    @Published var isPrivate = false
    @Published var maxMembers: Int
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    /// Faixa de membros — regra definida pelo Worker.
    var maxMembersRange: ClosedRange<Int> { worker.maxMembersRange }

    /// Habilita o botão de criar — regra definida pelo Worker.
    var canCreate: Bool {
        worker.canCreate(name: name, isPrivate: isPrivate, password: password) && !isLoading
    }

    init(worker: CreateGroupWorkerProtocol) {
        self.worker = worker
        self.maxMembers = worker.maxMembersRange.upperBound
    }

    func create() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let createdGroup = try await worker.createGroup(
                    name: name,
                    description: groupDescription,
                    isPrivate: isPrivate,
                    password: password,
                    maxMembers: maxMembers
                )
                await MainActor.run {
                    isLoading = false
                    // Quem cria já é membro: fecha o sheet (o `onDismiss` recarrega
                    // a Explore) e entra direto na tela do grupo recém-criado.
                    coordinator?.completeJoin(group: createdGroup)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func cancel() {
        coordinator?.dismissCreateGroup()
    }
}

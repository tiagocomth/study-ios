//
//  CreateGroupViewModel.swift
//  Study
//

import Foundation
import Combine
////NEXT1:LEMBRE REGRA DE NEGOCIO É NO WORKER E N NA VM NAO QUERO NENHUMA REGRA DE NEGOCIO NA VM 
final class CreateGroupViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: CreateGroupWorkerProtocol

    @Published var name = ""
    @Published var groupDescription = ""
    @Published var password = ""
    @Published var isPrivate = false
    @Published var maxMembers = 10
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    /// Faixa de membros permitida no grupo. O plano gratuito é limitado a 10
    /// membros pelo backend; ampliar quando o gating de premium estiver ligado.
    let maxMembersRange = 2...10

    var canCreate: Bool {
        let hasName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        // Grupo privado exige senha com pelo menos 4 caracteres.
        let hasValidPassword = !isPrivate || password.count >= 4
        return hasName && hasValidPassword && !isLoading
    }

    init(worker: CreateGroupWorkerProtocol) {
        self.worker = worker
    }

    func create() {
        guard !isLoading else { return }

        let name = name
        let description = groupDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        // Grupo privado = grupo com senha (o backend deriva `isPrivate` daí).
        let password = isPrivate ? password : nil
        let maxMembers = maxMembers

        isLoading = true
        errorMessage = nil

        Task {
            do {
                _ = try await worker.createGroup(
                    name: name,
                    description: description.isEmpty ? nil : description,
                    maxMembers: maxMembers,
                    password: password
                )
                await MainActor.run {
                    isLoading = false
                    // Fecha o sheet; o `onDismiss` do coordinator recarrega a Explore
                    // já com o novo grupo.
                    coordinator?.dismissCreateGroup()
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

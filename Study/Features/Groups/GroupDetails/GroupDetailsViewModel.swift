//
//  GroupDetailsViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class GroupDetailsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: GroupDetailsWorkerProtocol
    let group: StudyGroup

    @Published private(set) var status: GroupLiveStatus?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    /// "Relógio" local que avança a cada segundo para os cronômetros contarem
    /// ao vivo entre os polls do backend.
    @Published private(set) var now = Date()

    private var hasStarted = false
    private var tickCancellable: AnyCancellable?
    private var pollCancellable: AnyCancellable?

    /// Intervalo de poll do backend (a doc do endpoint indica 30s).
    private let pollInterval: TimeInterval = 30

    var groupName: String { status?.groupName ?? group.name }

    var activeMembers: [ActiveMember] { status?.activeMembers ?? [] }
    var inactiveMembers: [InactiveMember] { status?.inactiveMembers ?? [] }
    var hasAnyMember: Bool { !activeMembers.isEmpty || !inactiveMembers.isEmpty }

    /// "X de Y pessoas estão estudando agora".
    var statusText: String {
        let total = status?.totalMembers ?? 0
        let studying = activeMembers.count
        return "\(studying) de \(total) pessoas estão estudando agora"
    }

    init(group: StudyGroup, worker: GroupDetailsWorkerProtocol) {
        self.group = group
        self.worker = worker
    }

    /// Início — idempotente. Dispara a primeira carga e os timers.
    func onAppear() {
        guard !hasStarted else { return }
        hasStarted = true
        load()
        startTimers()
    }

    /// Para os timers ao sair da tela (evita poll/tick em background).
    func onDisappear() {
        tickCancellable = nil
        pollCancellable = nil
        hasStarted = false
    }

    func reload() {
        load()
    }

    func back() {
        coordinator?.pop()
    }

    /// Cronômetro formatado (HH:MM:SS) de um membro ativo, no instante `now`.
    func elapsedText(for member: ActiveMember) -> String {
        let total = Int(worker.elapsedSeconds(for: member, now: now))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func categoryText(for member: ActiveMember) -> String {
        guard let category = member.categoryName, !category.isEmpty else {
            return "Estudando"
        }
        return "Estudando \(category)"
    }

    // MARK: - Private

    private func startTimers() {
        // Tick local de 1s só atualiza o relógio (cronômetros recalculam sozinhos).
        tickCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in self?.now = date }

        // Poll do backend a cada 30s para atualizar quem está ativo/inativo.
        pollCancellable = Timer.publish(every: pollInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.load() }
    }

    private func load() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let status = try await worker.getLiveStatus(groupId: group.id)
                self.status = status
                self.now = Date()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

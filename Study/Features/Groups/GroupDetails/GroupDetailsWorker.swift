//
//  GroupDetailsWorker.swift
//  Study
//

import Foundation

protocol GroupDetailsWorkerProtocol {
    /// Busca o estado ao vivo do grupo (ativos/inativos) no backend.
    func getLiveStatus(groupId: String) async throws -> GroupLiveStatus

    /// Segundos de estudo já acumulados por um membro ativo até `now`,
    /// descontando as pausas. Congela enquanto o membro está pausado.
    func elapsedSeconds(for member: ActiveMember, now: Date) -> TimeInterval
}

final class GroupDetailsWorker: GroupDetailsWorkerProtocol {
    private let service: GroupServiceProtocol

    init(service: GroupServiceProtocol) {
        self.service = service
    }

    func getLiveStatus(groupId: String) async throws -> GroupLiveStatus {
        try await service.fetchActiveMembers(groupId: groupId)
    }

    func elapsedSeconds(for member: ActiveMember, now: Date) -> TimeInterval {
        // Pausado: o tempo para no instante em que pausou; senão, conta até agora.
        let referenceEnd = member.currentPauseStartedAt ?? now
        let raw = referenceEnd.timeIntervalSince(member.startedAt) - member.completedPausedSeconds
        return max(0, raw)
    }
}

//
//  GroupLiveStatus.swift
//  Study
//

import Foundation

/// Estado "ao vivo" de um grupo: quem está estudando agora e quem não está.
/// Vem de `GET /groups/{id}/members/active` (poll a cada 30s).
struct GroupLiveStatus {
    let groupName: String
    let ownerId: String
    let totalMembers: Int
    let activeMembers: [ActiveMember]
    let inactiveMembers: [InactiveMember]
}

/// Membro estudando agora.
struct ActiveMember: Identifiable, Hashable {
    let id: String            // userId
    let name: String
    let categoryName: String?

    /// Início da sessão de estudo atual.
    let startedAt: Date
    /// Soma das pausas já encerradas (descontadas do tempo estudado).
    let completedPausedSeconds: TimeInterval
    /// Quando a pausa em aberto começou (nil = não está pausado agora). Enquanto
    /// pausado, o cronômetro congela neste instante.
    let currentPauseStartedAt: Date?

    var isPaused: Bool { currentPauseStartedAt != nil }
}

/// Membro do grupo que não está estudando no momento.
struct InactiveMember: Identifiable, Hashable {
    let id: String            // userId
    let name: String
    let totalHours: Double
}

//
//  ActiveMembersResponseDTO.swift
//  Study
//

import Foundation

/// Espelha `GET /groups/{id}/members/active`.
struct ActiveMembersResponseDTO: Decodable {
    let groupId: String
    let groupName: String
    let ownerId: String
    let members: Members

    struct Members: Decodable {
        let total: Int
        let active: [ActiveMemberDTO]
        let inactive: [InactiveMemberDTO]
    }

    struct ActiveMemberDTO: Decodable {
        let userId: String
        let userName: String
        let startedAt: String
        let pauses: [PauseDTO]?
        let categoryName: String?
    }

    struct PauseDTO: Decodable {
        let pausedAt: String
        let resumedAt: String?

        // A API usa snake_case só aqui dentro das pausas.
        enum CodingKeys: String, CodingKey {
            case pausedAt = "paused_at"
            case resumedAt = "resumed_at"
        }
    }

    struct InactiveMemberDTO: Decodable {
        let userId: String
        let userName: String
        let totalHours: Double
    }

    /// Converte para o domínio. As datas chegam em ISO8601 (com frações), então
    /// usamos o `ISO8601DateParser`; a sessão sem `startedAt` válido é descartada.
    func toDomain(dateParser: DateParsing = ISO8601DateParser()) -> GroupLiveStatus {
        let active: [ActiveMember] = members.active.compactMap { dto in
            guard let startedAt = dateParser.parse(dto.startedAt) else { return nil }

            let pauses = dto.pauses ?? []
            // Pausas encerradas (com `resumed_at`): somamos a duração para descontar.
            let completedPaused = pauses.reduce(into: TimeInterval(0)) { acc, pause in
                guard let resumedAtString = pause.resumedAt,
                      let pausedAt = dateParser.parse(pause.pausedAt),
                      let resumedAt = dateParser.parse(resumedAtString) else { return }
                acc += resumedAt.timeIntervalSince(pausedAt)
            }
            // Pausa em aberto (sem `resumed_at`): congela o cronômetro nela.
            let currentPauseStartedAt = pauses
                .first { $0.resumedAt == nil }
                .flatMap { dateParser.parse($0.pausedAt) }

            return ActiveMember(
                id: dto.userId,
                name: dto.userName,
                categoryName: dto.categoryName,
                startedAt: startedAt,
                completedPausedSeconds: completedPaused,
                currentPauseStartedAt: currentPauseStartedAt
            )
        }

        let inactive = members.inactive.map {
            InactiveMember(id: $0.userId, name: $0.userName, totalHours: $0.totalHours)
        }

        return GroupLiveStatus(
            groupName: groupName,
            ownerId: ownerId,
            totalMembers: members.total,
            activeMembers: active,
            inactiveMembers: inactive
        )
    }
}

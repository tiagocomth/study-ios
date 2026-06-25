//
//  GroupDTO.swift
//  Study
//

import Foundation

/// Network representation of a group, shared by the Groups services
/// (Explore, Create, …). Mirrors `GroupResponseDto` from the API and maps to
/// the `StudyGroup` domain entity via `toDomain()`.
struct GroupDTO: Decodable {
    let groupId: String
    let ownerId: String
    let name: String
    let description: String?
    let isPrivate: Bool
    let maxMembers: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case groupId, ownerId, name, description, isPrivate, maxMembers, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groupId = try container.decode(String.self, forKey: .groupId)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        // `/groups/all` lista só grupos públicos e omite `isPrivate`; create/search
        // trazem o campo. Ausência = público (false).
        isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
        maxMembers = try container.decode(Int.self, forKey: .maxMembers)

        // A API envia ISO8601 com frações de segundo (ex.: "2026-06-23T20:42:49.869Z"),
        // que o `JSONDecoder` padrão não decodifica. Fazemos o parse aqui.
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = GroupDTO.dateFormatter.date(from: createdAtString) ?? Date()
    }

    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    func toDomain() -> StudyGroup {
        StudyGroup(
            id: groupId,
            ownerId: ownerId,
            name: name,
            description: description,
            isPrivate: isPrivate,
            maxMembers: maxMembers,
            createdAt: createdAt
        )
    }
}

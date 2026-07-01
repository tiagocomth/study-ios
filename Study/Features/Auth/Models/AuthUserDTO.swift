//
//  AuthUserDTO.swift
//  Study
//

import Foundation

/// `UserResponseDto` da API — traz `id` e `email`, e pode ou não incluir `is_premium`.
struct AuthUserDTO: Decodable {
    let id: String
    let email: String
    let isPremium: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case isPremium
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
    }
}

extension AuthUserDTO {
    /// Monta a entidade `User` a partir do que a API devolve. Como o backend pode
    /// omitir `is_premium`, os demais campos recebem defaults.
    /// - Parameter name: nome a usar; quando `nil`, cai no e-mail como placeholder.
    func toUser(name: String? = nil) -> User {
        User(
            id: id,
            name: name ?? email,
            photo: nil,
            isPremium: isPremium,
            individualHoursTotal: 0,
            groupHoursTotal: 0
        )
    }
}

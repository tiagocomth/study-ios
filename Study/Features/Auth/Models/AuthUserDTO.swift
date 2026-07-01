//
//  AuthUserDTO.swift
//  Study
//

import Foundation

/// `UserResponseDto` da API — hoje traz apenas `id` e `email`.
struct AuthUserDTO: Decodable {
    let id: String
    let email: String
    let isPremium: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case isPremium = "is_premium"
    }
}

extension AuthUserDTO {
    /// Monta a entidade `User` a partir do que a API devolve. Como o backend só
    /// retorna `id`/`email`/`is_premium`, os demais campos recebem defaults.
    /// - Parameter name: nome a usar; quando `nil`, cai no e-mail como placeholder.
    func toUser(name: String? = nil) -> User {
        User(
            id: id,
            name: name ?? email,
            isPremium: isPremium,
            photo: nil,
            individualHoursTotal: 0,
            groupHoursTotal: 0
        )
    }
}

//
//  AuthUserDTO.swift
//  Study
//

import Foundation

/// `UserResponseDto` da API — hoje traz apenas `id` e `email`.
/// (O Swagger anuncia `{ userId, name, isPremium, photoId }`, mas a resposta
/// real ainda é `{ id, email }`.)
struct AuthUserDTO: Decodable {
    let id: String
    let email: String
}

extension AuthUserDTO {
    /// Monta a entidade `User` a partir do que a API devolve. Como o backend só
    /// retorna `id`/`email`, os demais campos recebem defaults.
    /// - Parameter name: nome a usar; quando `nil`, cai no e-mail como placeholder.
    func toUser(name: String? = nil) -> User {
        User(
            id: id,
            name: name ?? email,
            photo: nil,
            individualHoursTotal: 0,
            groupHoursTotal: 0
        )
    }
}

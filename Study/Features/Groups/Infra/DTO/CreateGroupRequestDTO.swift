//
//  CreateGroupRequestDTO.swift
//  Study
//

import Foundation

/// Espelha `CreateGroupDto` — `{ name, description?, maxMembers?, password? }`.
/// `isPrivate` não entra no body; o backend infere pela presença de `password`.
struct CreateGroupRequestDTO: Encodable {
    let name: String
    let description: String?
    let maxMembers: Int?
    let password: String?
}

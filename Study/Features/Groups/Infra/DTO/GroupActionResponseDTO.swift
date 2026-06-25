//
//  GroupActionResponseDTO.swift
//  Study
//

import Foundation

/// Espelha `GroupActionResponseDto` (`{ message, data }`) — resposta de ações
/// que devolvem um grupo (ex.: criação).
struct GroupActionResponseDTO: Decodable {
    let message: String?
    let data: GroupDTO
}

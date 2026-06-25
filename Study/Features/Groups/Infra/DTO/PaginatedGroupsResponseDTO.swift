//
//  PaginatedGroupsResponseDTO.swift
//  Study
//

import Foundation

/// Espelha `PaginatedGroupsResponseDto` (`{ total, data }`).
struct PaginatedGroupsResponseDTO: Decodable {
    let total: Int
    let data: [GroupDTO]
}

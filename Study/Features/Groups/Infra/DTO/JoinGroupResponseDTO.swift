//
//  JoinGroupResponseDTO.swift
//  Study
//

import Foundation

/// Resposta do `POST /groups/{id}/join` (`201` com `{ message }`).
struct JoinGroupResponseDTO: Decodable {
    let message: String?
}

//
//  AuthResponseDTO.swift
//  Study
//

import Foundation

/// `LoginResponseDto` / `RegisterResponseDto` — token + usuário.
struct AuthResponseDTO: Decodable {
    let accessToken: String
    let user: AuthUserDTO
}

extension AuthResponseDTO {
    func toDomain(name: String? = nil) -> AuthResponse {
        AuthResponse(user: user.toUser(name: name), token: accessToken)
    }
}

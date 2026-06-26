//
//  RegisterRequestDTO.swift
//  Study
//

import Foundation

/// `POST /auth/register` — body com nome + e-mail + senha.
struct RegisterRequestDTO: Encodable {
    let name: String
    let email: String
    let password: String
}

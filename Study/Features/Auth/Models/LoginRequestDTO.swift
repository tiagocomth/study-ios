//
//  LoginRequestDTO.swift
//  Study
//

import Foundation

/// `POST /auth/login` — body com e-mail + senha.
struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

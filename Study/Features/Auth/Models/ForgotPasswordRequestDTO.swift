//
//  ForgotPasswordRequestDTO.swift
//  Study
//

import Foundation

/// `POST /auth/forgot-password` — dispara o envio do código de reset.
struct ForgotPasswordRequestDTO: Encodable {
    let email: String
}

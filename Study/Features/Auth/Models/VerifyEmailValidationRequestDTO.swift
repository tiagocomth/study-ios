//
//  VerifyEmailValidationRequestDTO.swift
//  Study
//

import Foundation

/// Confirma o código de validação de e-mail do cadastro.
/// `POST /auth/register/verify` — body `email` + `otp`.
struct VerifyEmailValidationRequestDTO: Encodable {
    let email: String
    let otp: String
}

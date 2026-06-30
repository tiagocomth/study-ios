//
//  ValidateResetCodeRequestDTO.swift
//  Study
//

import Foundation

/// Valida o código de reset de senha recebido por e-mail.
struct ValidateResetCodeRequestDTO: Encodable {
    let email: String
    let otp: String
}

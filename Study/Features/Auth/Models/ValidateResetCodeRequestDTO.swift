//
//  ValidateResetCodeRequestDTO.swift
//  Study
//

import Foundation

/// Valida o código de reset de senha recebido por e-mail.
struct ValidateResetCodeRequestDTO: Encodable {
    let code: String
}

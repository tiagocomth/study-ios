//
//  ValidateResetCodeResponseDTO.swift
//  Study
//

import Foundation

/// Resposta da validação do código de reset — devolve o OTP usado nas próximas chamadas.
struct ValidateResetCodeResponseDTO: Decodable {
    let otp: String
}

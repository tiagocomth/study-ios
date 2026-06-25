//
//  NewPasswordRequestDTO.swift
//  Study
//

import Foundation

/// O OTP (token de reset) viaja como bearer token, então o body leva só a senha.
struct NewPasswordRequestDTO: Encodable {
    let password: String
}

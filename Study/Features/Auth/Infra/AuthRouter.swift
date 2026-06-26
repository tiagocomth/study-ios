//
//  AuthRouter.swift
//  Study
//
//  Created by Caio Mandarino on 17/06/26.
//

import Foundation

enum AuthRouter: Hashable, Identifiable {
    var id: Self { self }
    
    case forgotPassword
    case code
    case newPassword
    case register
    case emailValidate(email: Email)
}

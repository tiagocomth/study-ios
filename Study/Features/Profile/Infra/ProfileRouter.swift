//
//  ProfileRouter.swift
//  Study
//
//  Created by Breno Marques on 23/06/26.
//

import Foundation


enum ProfileRouter: Hashable, Identifiable {
    var id: Self { self }
    
    case premium
    case logoutConfirmation
    case editProfile
}

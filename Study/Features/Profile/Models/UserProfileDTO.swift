//
//  UserProfileDTO.swift
//  Study
//
//  Created by Breno Marques on 25/06/26.
//

import Foundation

struct UserProfileDTO: Decodable {
    let userId: String
    let name: String
    let isPremium: Bool
    let photoId: String?
}

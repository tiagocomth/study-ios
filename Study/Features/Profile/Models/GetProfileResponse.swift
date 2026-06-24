//
//  GetProfileResponse.swift
//  Study
//
//  Created by Breno Marques on 23/06/26.
//

import Foundation


struct GetProfileResponse: Decodable {
    let userId: String
    let name: String
    let isPremium: Bool
    let photoId: String?
}

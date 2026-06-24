//
//  UpdateProfileResponse.swift
//  Study
//
//  Created by Breno Marques on 23/06/26.
//

import Foundation

struct UpdateProfileResponse: Decodable {
    let message: String
    let data: GetProfileResponse
}

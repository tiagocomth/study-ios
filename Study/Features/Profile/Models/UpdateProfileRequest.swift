//
//  UpdateProfileRequest.swift
//  Study
//
//  Created by Breno Marques on 24/06/26.
//

import Foundation

struct UpdateProfileRequest: Encodable {
    let name: String
    let photoId: Int
}

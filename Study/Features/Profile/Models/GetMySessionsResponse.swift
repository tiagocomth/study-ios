//
//  GetMySessionsResponse.swift
//  Study
//
//  Created by Breno Marques on 24/06/26.
//

import Foundation

struct GetMySessionsResponse: Decodable {
    let user: UserProfileDTO
    let sessions: [SessionDTO]
}


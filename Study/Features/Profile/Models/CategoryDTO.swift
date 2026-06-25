//
//  CategoryDTO.swift
//  Study
//
//  Created by Breno Marques on 25/06/26.
//

import Foundation

struct CategoryDTO: Decodable {
    let categoryId: String
    let userId: String
    let name: String
    let createdAt: String
    let isDeleted: Bool
}

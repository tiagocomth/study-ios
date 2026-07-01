//
//  User.swift
//  Study
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let photo: String?
    let isPremium: Bool
    let individualHoursTotal: Double
    let groupHoursTotal: Double
}

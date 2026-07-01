//
//  User.swift
//  Study
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let isPremium: Bool
    let photo: String?
    let individualHoursTotal: Double
    let groupHoursTotal: Double
}

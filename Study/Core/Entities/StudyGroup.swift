//
//  StudyGroup.swift
//  Study
//

import Foundation

struct StudyGroup: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let createdAt: Date
    let password: String?
    let adminName: String
    let users: [User]
}

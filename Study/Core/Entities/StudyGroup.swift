//
//  StudyGroup.swift
//  Study
//

import Foundation

struct StudyGroup: Identifiable {
    let id: String
    let ownerId: String
    let name: String
    let description: String?
    let isPrivate: Bool
    let maxMembers: Int
    let createdAt: Date
}

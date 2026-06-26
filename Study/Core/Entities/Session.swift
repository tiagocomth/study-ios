//
//  Session.swift
//  Study
//

import Foundation

struct Session: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let categoryId: String
    let startedAt: Date
    let endedAt: Date
    let duration: Int
}

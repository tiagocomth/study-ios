//
//  Profile.swift
//  Study
//

import Foundation

struct Profile: Equatable {
    let id: String
    let name: String
    let isPremium: Bool
    let photoId: String?
    let hoursStudiedToday: Double
    let hoursStudiedThisWeek: Double
    let hoursStudiedThisMonth: Double
    let sessions: [Session]
}

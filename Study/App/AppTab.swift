//
//  AppTab.swift
//  Study
//

import Foundation

enum AppTab: Hashable {
    case studySessions
    case exploreGroups
    case myGroups
    case myGroup(id: UUID)
    case profile
}

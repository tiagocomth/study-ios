//
//  GroupsPage.swift
//  Study
//

import Foundation

/// Uma página de grupos vinda do backend, com o total para a paginação.
struct GroupsPage {
    let groups: [StudyGroup]
    let total: Int
}

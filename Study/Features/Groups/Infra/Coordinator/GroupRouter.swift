//
//  GroupRouter.swift
//  Study
//

import Foundation

enum GroupRouter: Hashable, Identifiable {
    var id: Self { self }

    /// Apresentada como sheet a partir da Explore.
    case createGroup
}

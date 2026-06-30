//
//  GroupRouter.swift
//  Study
//

import Foundation

enum GroupRouter: Hashable, Identifiable {
    var id: Self { self }

    /// Apresentada como sheet a partir da Explore.
    case createGroup

    /// Pop-up (sheet) de entrada em um grupo, aberto ao tocar num item da Explore.
    case joinGroup(StudyGroup)

    /// Tela de membros (push), exibida após entrar no grupo.
    case groupDetails(StudyGroup)
}

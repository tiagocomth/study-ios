//
//  GroupPrivacyFilter.swift
//  Study
//

import Foundation

/// Filtro de privacidade do segmented control da Explore.
/// Tipo puro: a tradução para o contrato da API (`isPrivate`) é responsabilidade
/// do Worker, e o texto exibido é responsabilidade da View.
enum GroupPrivacyFilter: CaseIterable, Identifiable {
    case all
    case `public`
    case `private`

    var id: Self { self }
}

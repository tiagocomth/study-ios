//
//  ProfileRouter.swift
//  Study
//
//  Created by Breno Marques on 23/06/26.
//

import Foundation


enum ProfileRouter: Hashable, Identifiable {
    var id: Self { self }
    
    // TODO: Analisar melhor as rotas a partir da tela de Perfil
    case premium
}

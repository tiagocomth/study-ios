//
//  NavigationFactory.swift
//  Challenge13
//
//  Created by Caio Mandarino on 02/04/26.
//

import SwiftUI

struct NavigationFactory: Equatable {
    let id: String
    let factory: (Any) -> AnyView

    init<D, C>(_ data: D.Type, _ factory: @escaping (D) -> C) where D: Hashable & Identifiable, C: View {
        self.id = String(describing: data)
        self.factory = { value in
             
            if let value = value as? D {
                return AnyView(factory(value))
            } else {
                return AnyView(Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow))
            }
        }
    }
    
    static func == (lhs: NavigationFactory, rhs: NavigationFactory) -> Bool { lhs.id == rhs.id }
}

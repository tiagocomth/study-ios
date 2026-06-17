//
//  SheetFactoryKey.swift
//  Challenge13
//
//  Created by Caio Mandarino on 02/04/26.
//

import SwiftUI

struct SheetFactoryKey: PreferenceKey {
    static let defaultValue: [String : NavigationFactory] = [:]
    
    static func reduce(value: inout [String : NavigationFactory], nextValue: () -> [String : NavigationFactory]) {
        value.merge(nextValue()) { $1 }
    }
}

extension View {
    public func sheetDestination<D, C>(for data: D.Type, @ViewBuilder factory: @escaping (D) -> C ) -> some View where D: Identifiable & Hashable, C: View {
        preference(key: SheetFactoryKey.self, value: [ String(describing: data) : NavigationFactory(data, factory)])
    }
}

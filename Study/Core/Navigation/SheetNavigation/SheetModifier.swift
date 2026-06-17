//
//  SheetModifier.swift
//  Challenge13
//
//  Created by Caio Mandarino on 02/04/26.
//

import SwiftUI

struct SheetModifier: ViewModifier {
    
    @Binding var sheetPath: SheetPath
    @State private var factories: [String : NavigationFactory] = [:]
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(SheetFactoryKey.self) { factories = $0 }
            .sheet(item: _sheetPath.sheet, onDismiss: sheetPath.sheet?.onDismiss) { factories[sheetPath.id]?.factory($0.sheet) }
    }
}

extension View {
    func sheet(for sheet: Binding<SheetPath>) -> some View {
        modifier(SheetModifier(sheetPath: sheet))
    }
}

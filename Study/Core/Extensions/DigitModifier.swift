//
//  DigitModifier.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import SwiftUI

struct DigitModifier: ViewModifier {
    let font: Font
    let value: Double
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .fontWeight(.semibold)
            .frame(maxHeight: 40)
            .monospaced()
            .contentTransition(.numericText(value: value))
            .animation(.easeOut(duration: 0.8), value: value)
            .padding()
    }
}

extension View {
    public func digitStyle(font: Font, value: Double) -> some View {
        modifier(DigitModifier(font: font, value: value))
    }
}

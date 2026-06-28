//
//  PrimaryButtonStyle.swift
//  Study
//
//  Created by Breno Marques on 26/06/26.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {

        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                isEnabled
                ? AppColors.primary
                : AppColors.primaryDisabled
            )
            .overlay {
                Capsule()
                    .stroke(.black, lineWidth: 2)
            }
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.25),
                    radius: 4,
                    y: 3)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

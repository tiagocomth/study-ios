//
//  SecondaryButtonStyle.swift
//  Study
//
//  Created by Breno Marques on 26/06/26.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {

        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppColors.secondaryPure)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(.white)
            .overlay {
                Capsule()
                    .stroke(.black, lineWidth: AppBorder.width)
            }
            .clipShape(Capsule())
            .shadow(
                color: .black.opacity(0.25),
                radius: AppShadow.radius,
                y: AppShadow.y
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

}

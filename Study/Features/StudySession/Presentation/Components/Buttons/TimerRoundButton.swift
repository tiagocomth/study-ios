//
//  TimerRoundButton.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import SwiftUI

struct TimerRoundButton: View {
    let backgroundColor: Color
    let symbolName: String
    let symbolColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(symbolColor)
                .frame(width: 60, height: 60)
                .background(backgroundColor)
                .overlay {
                    Circle()
                        .stroke(AppColors.neutralBlack, lineWidth: 2)
                }
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
        }
        .buttonStyle(.studyStyle)
    }
}

#Preview {
    TimerRoundButton(backgroundColor: .red, symbolName: "", symbolColor: .red) {
        
    }
}

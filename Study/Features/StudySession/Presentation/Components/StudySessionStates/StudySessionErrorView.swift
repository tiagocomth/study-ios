//
//  StudySessionErrorView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionErrorView: View {
    let errorMessage: String?

    var body: some View {
        VStack(spacing: GlobalConfiguration.normalSpacing) {
            Spacer()

            Text("Não foi possível carregar suas matérias.")
                .font(.headline)
                .foregroundStyle(AppColors.neutralBlack)

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.neutralGray)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StudySessionErrorView(errorMessage: "Erro ao carregar matérias")
}

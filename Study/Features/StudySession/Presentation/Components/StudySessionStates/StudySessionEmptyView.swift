//
//  StudySessionEmptyView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionEmptyView: View {
    
    let onAddCategory: () -> Void

    var body: some View {
        VStack(spacing: GlobalConfiguration.normalSpacing) {
            Spacer()

            StudySessionAddCardView(action: onAddCategory)
                .frame(maxWidth: 100, maxHeight: 100)

            Text("Parece que você ainda não adicionou\nnenhuma matéria ainda!")
                .font(.title2)
                .foregroundStyle(AppColors.neutralGray)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StudySessionEmptyView(onAddCategory: {})
}

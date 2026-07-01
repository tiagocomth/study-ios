//
//  StudySessionAddCardView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionAddCardView: View {
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: AppRadius.small)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.small)
                        .stroke()
                        .foregroundStyle(AppColors.neutralBlack)
                }
                .overlay {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColors.neutralBlack)
                        .frame(maxWidth: 25, maxHeight: 25)
                }
        }
        .buttonStyle(.studyStyle)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    StudySessionAddCardView() {}
}

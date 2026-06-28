//
//  StudySessionSelectedCardView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionSelectedCardView: View {
    
    let categoryName: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: AppRadius.small)
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.small)
                        .stroke()
                        .foregroundStyle(.red)
                }
                .aspectRatio(1, contentMode: .fit)
            
            Text(categoryName)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.neutralBlack)
        }
    }
}

#Preview {
    StudySessionSelectedCardView(categoryName: "Português")
}

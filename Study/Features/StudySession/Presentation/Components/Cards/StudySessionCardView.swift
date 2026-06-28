//
//  StudySessionCardView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionCardView: View {
    
    let categoryName: String
    let action: () -> Void
    
    var body: some View {
    
        VStack {
            Button(action: action) {
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.small)
                            .stroke()
                            .foregroundStyle(.neutralColorblack)
                    }
            }
            .buttonStyle(.studyStyle)
            .aspectRatio(1, contentMode: .fit)
            
            Text(categoryName)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.neutralBlack)
        }
        
    }
}

#Preview {
    StudySessionCardView(categoryName: "Português") { }
}

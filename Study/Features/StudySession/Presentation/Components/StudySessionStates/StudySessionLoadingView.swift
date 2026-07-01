//
//  StudySessionLoadingView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionLoadingView: View {
    
    var body: some View {
        VStack(spacing: GlobalConfiguration.normalSpacing) {
            Spacer()
            
            Color(AppColors.neutralBlack)
                .mask {
                    ProgressView()
                }
                .padding(.zero)
                .frame(maxWidth: 30, maxHeight: 30)
            
            Text("Carregando matérias...")
                .font(.headline)
                .foregroundStyle(AppColors.neutralBlack)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StudySessionLoadingView()
}

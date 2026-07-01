//
//  StudySessionHeaderView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionHeaderView: View {
    let subTitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: GlobalConfiguration.largeSpacing) {
            Text("Meus Estudos")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.neutralBlack)
            
            VStack(alignment: .leading, spacing: GlobalConfiguration.normalSpacing) {
                Text("Qual matéria você estudará hoje?")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.neutralBlack)

                Text(subTitle)
                    .font(.title2)
                    .foregroundStyle(AppColors.neutralBlack)
            }
        }
    }
}

#Preview {
    StudySessionHeaderView(subTitle: "Selecione sua matéria")
}

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
                        .foregroundStyle(.neutralColorblack)
                }
                .overlay {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .foregroundStyle(.neutralColorblack)
                }
        }
        .buttonStyle(.studyStyle)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    StudySessionAddCardView() {}
}

//
//  StudySessionTimerModeCardView.swift
//  Study
//

import SwiftUI

struct StudySessionTimerModeCardView: View {
    let option: StudySessionViewModel.TimerModeOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(option.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.neutralBlack)
                    .multilineTextAlignment(.center)

                RoundedRectangle(cornerRadius: AppRadius.small)
                    .fill(AppColors.neutralWhite)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: option.symbolName)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .foregroundStyle(AppColors.primary)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.small)
                            .stroke(AppColors.neutralBlack, lineWidth: 1)
                    }

                Text(option.subtitle)
                    .font(.body)
                    .foregroundStyle(AppColors.neutralBlack)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(GlobalConfiguration.normalPadding)
            .background(AppColors.primaryLight)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .stroke(AppColors.neutralBlack, lineWidth: isSelected ? 3 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
            .shadow(color: .black, radius: AppShadow.radius, y: AppShadow.y)
            .opacity(isSelected ? 1 : 0.75)
        }
        .aspectRatio(0.70, contentMode: .fit)
        .buttonStyle(.studyStyle)
    }
}

#Preview {
    HStack(spacing: 24) {
        StudySessionTimerModeCardView(
            option: .stopwatch,
            isSelected: false,
            action: {}
        )
       

        StudySessionTimerModeCardView(
            option: .countdown,
            isSelected: true,
            action: {}
        )
    }
    .padding(40)
    .background(Color.gray.opacity(0.2))
}

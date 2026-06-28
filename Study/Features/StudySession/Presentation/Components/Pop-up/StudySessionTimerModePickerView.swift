//
//  StudySessionTimerModePickerView.swift
//  Study
//

import SwiftUI

struct StudySessionTimerModePickerView: View {
    let selectedOption: StudySessionViewModel.TimerModeOption?
    let canConfirm: Bool
    let onBack: () -> Void
    let onSelect: (StudySessionViewModel.TimerModeOption) -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: GlobalConfiguration.largePadding) {
            Button(action: onBack) {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColors.neutralBlack)
                    .frame(maxWidth: 25, maxHeight: 25)
            }
            .buttonStyle(.studyStyle)
            
            HStack {
                ForEach(StudySessionViewModel.TimerModeOption.allCases, id: \.self) { option in
                    StudySessionTimerModeCardView(
                        option: option,
                        isSelected: selectedOption == option,
                        action: { onSelect(option) }
                    )
                    .padding(.horizontal)
                }
            }
            
            Button(action: onConfirm) {
                Text("Iniciar Estudos")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!canConfirm)
            .padding(.horizontal, GlobalConfiguration.largePadding)
        }
        .padding()
        .aspectRatio(1, contentMode: .fit)
        .background(AppColors.neutralWhite)
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.small)
                .stroke(AppColors.neutralBlack, lineWidth: AppBorder.width)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
        .shadow(color: .black, radius: AppShadow.radius, y: AppShadow.y)
    }
}

#Preview {
    StudySessionTimerModePickerView(
        selectedOption: .countdown,
        canConfirm: true,
        onBack: {},
        onSelect: { _ in },
        onConfirm: {}
    )
    .padding(40)
    .background(Color.gray.opacity(0.3))
}

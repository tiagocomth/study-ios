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
        StudySessionPickerContainerView(
            canConfirm: canConfirm,
            onBack: onBack,
            onConfirm: onConfirm
        ) {
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
        }
    }
}

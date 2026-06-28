//
//  StudySessionView.swift
//  Study
//

import SwiftUI

struct StudySessionView: View {
    @StateObject var viewModel: StudySessionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            StudySessionHeaderView()
            
            StudySessionContentView(viewModel: viewModel)
            
            if viewModel.shouldShowPrimaryButton {
                footerButton
            }
        }
        .padding(GlobalConfiguration.normalPadding)
        .disabled(viewModel.shouldDisableClick())
        .background(AppColors.neutralWhite)
        .onTapGesture {
            viewModel.dismissDeleteCategory()
            viewModel.dismissEdit()
        }
        .overlay {
            if viewModel.isCountdownDurationPickerPresented {
                countdownTimerPicker
            } else if viewModel.isTimerModePickerPresented {
                choiceTimerPicker
            } else if viewModel.categoryPendingDeletion != nil {
                confirmationDeletion
            }
        }
        .task {
            viewModel.onViewAppear()
        }
    }
}

private extension StudySessionView {
    enum TimerPickerLayout {
        static let maxWidth: CGFloat = GlobalConfiguration.minimumWindowWidth
        static let height: CGFloat = GlobalConfiguration.minimumWindowHeight
    }
    
    var footerButton: some View {
        Button(action: viewModel.didTapPrimaryButton) {
            Text(viewModel.primaryButtonTitle)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.canStartTimer)
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity)
        .opacity(viewModel.isTimerModePickerPresented || viewModel.isCountdownDurationPickerPresented ? 0 : 1)
    }
    
    var choiceTimerPicker: some View {
        StudySessionTimerModePickerView(
            selectedOption: viewModel.selectedTimerModeOption,
            canConfirm: viewModel.canConfirmTimerModeSelection,
            onBack: viewModel.dismissTimerModePicker,
            onSelect: viewModel.selectTimerModeOption,
            onConfirm: viewModel.confirmTimerModeSelection
        )
        .padding()
        .frame(
            maxWidth: TimerPickerLayout.maxWidth,
            minHeight: TimerPickerLayout.height,
            maxHeight: TimerPickerLayout.height
        )
    }
    
    var countdownTimerPicker: some View {
        StudySessionCountdownDurationPickerView(
            hoursText: Binding(
                get: { viewModel.countdownHoursText },
                set: viewModel.updateCountdownHoursText
            ),
            minutesText: Binding(
                get: { viewModel.countdownMinutesText },
                set: viewModel.updateCountdownMinutesText
            ),
            secondsText: Binding(
                get: { viewModel.countdownSecondsText },
                set: viewModel.updateCountdownSecondsText
            ),
            canConfirm: viewModel.canConfirmCountdownDurationSelection,
            onBack: viewModel.navigateBackFromCountdownDurationPicker,
            onConfirm: viewModel.confirmCountdownDurationSelection
        )
        .padding()
        .frame(
            maxWidth: TimerPickerLayout.maxWidth,
            minHeight: TimerPickerLayout.height,
            maxHeight: TimerPickerLayout.height
        )
    }
    
    var confirmationDeletion: some View {
        StudySessionDeleteConfirmationView(
            title: "Deseja Excluir sua matéria?",
            onCancel: {
                viewModel.dismissDeleteCategory()
            },
            onConfirmDelete: {
                viewModel.confirmDeletePendingCategory()
            }
        )
    }
}

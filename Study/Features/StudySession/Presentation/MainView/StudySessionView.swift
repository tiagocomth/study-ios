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
        .background(AppColors.neutralWhite.ignoresSafeArea())
        .disabled(viewModel.shouldDisableClick())
        .onTapGesture {
            viewModel.dismissDeleteCategory()
            viewModel.dismissEdit()
            viewModel.dismissTimerModePicker()
        }
        .overlay {
            if viewModel.isTimerModePickerPresented {
                
                timerPicker
                
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
    var footerButton: some View {
        Button(action: viewModel.didTapPrimaryButton) {
            Text(viewModel.primaryButtonTitle)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.canStartTimer)
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity)
        .opacity(viewModel.isTimerModePickerPresented ? 0 : 1)
    }
    
    var timerPicker: some View {
        StudySessionTimerModePickerView(
            selectedOption: viewModel.selectedTimerModeOption,
            canConfirm: viewModel.canConfirmTimerModeSelection,
            onBack: viewModel.dismissTimerModePicker,
            onSelect: viewModel.selectTimerModeOption,
            onConfirm: viewModel.confirmTimerModeSelection
        )
        .padding(.horizontal, GlobalConfiguration.largePadding)
        .frame(maxHeight: 500)
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

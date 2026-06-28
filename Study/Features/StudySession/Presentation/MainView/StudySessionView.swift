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
        .onTapGesture {
            viewModel.dismissDeleteCategory()
            viewModel.dismissEdit()
        }
        .overlay {
            if let categoryPendingDeletion = viewModel.categoryPendingDeletion {
                deleteConfirmationOverlay(for: categoryPendingDeletion)
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
    }

    func deleteConfirmationOverlay(for _: StudyCategory) -> some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.dismissDeleteCategory()
                }

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
}

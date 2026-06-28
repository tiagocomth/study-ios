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
}

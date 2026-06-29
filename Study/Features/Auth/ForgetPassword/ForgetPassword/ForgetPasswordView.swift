//
//  ForgetPasswordView.swift
//  Study
//

import SwiftUI

struct ForgetPasswordView: View {
    @StateObject var viewModel: ForgetPasswordViewModel
    
    var body: some View {
        HStack() {
            leftPanel
            
            Divider()
            
            rightPanel
            
        }
        .navigationTitle("Esqueci Senha")
    }
}

private extension ForgetPasswordView {

    var leftPanel: some View {
        Image("login")
            .resizable()
            .scaledToFill()
            .clipped()
    }

    var rightPanel: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Esqueci Senha")
                .font(.largeTitle.bold())

            forgetPasswordForm

            Spacer()
        }
        .frame(maxWidth: 420)
        .padding(60)
    }

    var forgetPasswordForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            AuthTextField(
                title: "E-mail",
                placeholder: "Digite seu e-mail",
                text: $viewModel.emailValue
            )
            .autocorrectionDisabled()

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(AppColors.secondaryPure)
                    .font(.footnote)
            }

            Button {
                viewModel.recoverPassword()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Próximo")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }
}

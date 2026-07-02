//
//  ForgetPasswordView.swift
//  Study
//

import SwiftUI

struct ForgetPasswordView: View {
    @StateObject var viewModel: ForgetPasswordViewModel
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        AuthResponsiveContainer(
            title: "Esqueci Senha",
            subtitle: nil,
            onBack: { viewModel.coordinator?.navigateBack() }
        ) {
            forgetPasswordForm
        }
        .navigationTitle("Esqueci Senha")
    }
}

private extension ForgetPasswordView {

    var forgetPasswordForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            AuthTextField(
                title: "E-mail",
                placeholder: "Digite seu e-mail",
                text: $viewModel.emailValue,
                isFocused: $isEmailFocused
            )
            .autocorrectionDisabled()
            .onSubmit {
                if viewModel.isFormValid && !viewModel.isLoading {
                    viewModel.recoverPassword()
                }
            }

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

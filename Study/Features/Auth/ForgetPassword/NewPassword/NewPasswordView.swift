//
//  NewPasswordView.swift
//  Study
//

import SwiftUI

struct NewPasswordView: View {
    @StateObject var viewModel: NewPasswordViewModel
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool

    var body: some View {
        AuthResponsiveContainer(
            title: "Esqueci Senha",
            subtitle: "Crie uma nova senha segura para sua conta.",
            isHeaderCentered: true,
            onBack: { viewModel.coordinator?.navigateBack() }
        ) {
            newPasswordForm
        }
        .navigationTitle("Nova senha")
    }
}

private extension NewPasswordView {

    var newPasswordForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            AuthTextField(
                title: "Senha",
                placeholder: "Digite sua nova senha",
                isSecure: true,
                text: $viewModel.passwordValue,
                isFocused: $isPasswordFocused
            )
            .onSubmit {
                isConfirmPasswordFocused = true
            }

            AuthTextField(
                title: "Confirmar senha",
                placeholder: "Confirme sua nova senha",
                isSecure: true,
                text: $viewModel.passwordConfirmationValue,
                isFocused: $isConfirmPasswordFocused
            )
            .onSubmit {
                if viewModel.isFormValid && !viewModel.isLoading {
                    viewModel.updatePassword()
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(AppColors.secondaryPure)
                    .font(.footnote)
            }

            Button {
                viewModel.updatePassword()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Confirmar")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }
}

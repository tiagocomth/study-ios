//
//  NewPasswordView.swift
//  Study
//

import SwiftUI

struct NewPasswordView: View {
    @StateObject var viewModel: NewPasswordViewModel

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
                text: $viewModel.passwordValue
            )

            AuthTextField(
                title: "Confirmar senha",
                placeholder: "Confirme sua nova senha",
                isSecure: true,
                text: $viewModel.passwordConfirmationValue
            )

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

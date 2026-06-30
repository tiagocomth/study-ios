//
//  NewPasswordView.swift
//  Study
//

import SwiftUI

struct NewPasswordView: View {
    @StateObject var viewModel: NewPasswordViewModel

    var body: some View {
        HStack(spacing: 0) {
            leftPanel

            Divider()

            rightPanel
        }
        .navigationTitle("Nova senha")
    }
}

private extension NewPasswordView {

    var leftPanel: some View {
        Image("login")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .clipped()
    }

    var rightPanel: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(alignment: .center, spacing: 10) {
                Text("Esqueci Senha")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text("Crie uma nova senha segura para sua conta.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            newPasswordForm

            Spacer()
        }
        .frame(maxWidth: 420)
        .padding(60)
        .frame(maxWidth: .infinity)
    }

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

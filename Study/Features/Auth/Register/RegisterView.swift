//
//  RegisterView.swift
//  Study
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel
    
    var body: some View {
        AuthResponsiveContainer(
            title: "Criar conta",
            subtitle: nil,
            onBack: { viewModel.coordinator?.navigateBack() }
        ) {
            registerForm
        }
        .navigationTitle("Cadastro")
    }
}

private extension RegisterView {

    var registerForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            AuthTextField(
                title: "Nome",
                placeholder: "Digite seu nome",
                text: $viewModel.name
            )

            AuthTextField(
                title: "E-mail",
                placeholder: "Digite seu e-mail",
                text: $viewModel.email
            )
            .autocorrectionDisabled()

            AuthTextField(
                title: "Senha",
                placeholder: "Digite sua senha",
                isSecure: true,
                text: $viewModel.password
            )

            AuthTextField(
                title: "Repetir senha",
                placeholder: "Confirme sua senha",
                isSecure: true,
                text: $viewModel.confirmPassword
            )

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(AppColors.secondaryPure)
                    .font(.footnote)
            }

            Button {
                viewModel.register()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Cadastrar")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }
}

//
//  RegisterView.swift
//  Study
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            leftPanel
            
            Divider()
            
            rightPanel
        }
        .navigationTitle("Cadastro")
    }
}

private extension RegisterView {

    var leftPanel: some View {
        Image("login")
            .resizable()
            .scaledToFill()
            .clipped()
    }

    var rightPanel: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Criar conta")
                .font(.largeTitle.bold())

            registerForm

            Spacer()
        }
        .frame(maxWidth: 420)
        .padding(60)
    }

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

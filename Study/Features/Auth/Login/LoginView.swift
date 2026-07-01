//
//  LoginView.swift
//  Study
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        AuthResponsiveContainer(title: "Login", subtitle: nil) {
            loginForm

            Button("Não tem uma conta? Criar conta") {
                viewModel.navigateToRegister()
            }
            .buttonStyle(.link)
        }
    }
}

private extension LoginView {

    var loginForm: some View {

        VStack(alignment: .leading, spacing: 20) {

            AuthTextField(
                title: "E-mail",
                placeholder: "Digite seu e-mail",
                text: $viewModel.email
            )

            AuthTextField(
                title: "Senha",
                placeholder: "Digite sua senha",
                isSecure: true,
                text: $viewModel.password,
            )

            HStack {

                Spacer()

                Button("Esqueceu a senha?") {
                    viewModel.navigateToForgotPassword()
                }
                .buttonStyle(.link)
                
                Spacer()

            }

            if let error = viewModel.errorMessage {

                Text(error)
                    .foregroundStyle(AppColors.secondaryPure)
                    .font(.footnote)

            }

            Button {

                viewModel.login()

            } label: {

                if viewModel.isLoading {

                    ProgressView()
                        .frame(maxWidth: .infinity)

                } else {

                    Text("Entrar")
                        .frame(maxWidth: .infinity)

                }

            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFormValid)

        }

    }
}

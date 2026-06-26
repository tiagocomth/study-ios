//
//  LoginView.swift
//  Study
//

import SwiftUI

struct LoginView: View {

    @StateObject var viewModel: LoginViewModel

    var body: some View {
        GeometryReader { geometry in
            let halfWidth = (geometry.size.width - 1) / 2

            HStack(spacing: 0) {
                leftPanel
                    .frame(width: halfWidth)

                Divider()

                rightPanel
                    .frame(width: halfWidth)
            }
        }
    }
}

private extension LoginView {

    var leftPanel: some View {
        Image("login")
            .resizable()
            .scaledToFill()
            .clipped()
    }

    var rightPanel: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Login")
                .font(.largeTitle.bold())

            loginForm

            Spacer()

            Button("Não tem uma conta? Criar conta") {
                viewModel.navigateToRegister()
            }
            .buttonStyle(.link)
        }
        .frame(maxWidth: 420)
        .padding(60)

    }

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

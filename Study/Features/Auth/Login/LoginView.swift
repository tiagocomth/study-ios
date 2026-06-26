//
//  LoginView.swift
//  Study
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Login")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("E-mail", text: $viewModel.email)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Senha", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isFormValid || viewModel.isLoading)

            Button("Esqueci minha senha") {
                viewModel.navigateToForgotPassword()
            }
            .font(.footnote)

            Spacer()

            Button("Não tem uma conta? Cadastre-se") {
                viewModel.navigateToRegister()
            }
        }
        .padding()
    }
}

//
//  RegisterView.swift
//  Study
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Criar conta")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Nome", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)

                TextField("E-mail", text: $viewModel.email)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Senha", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                SecureField("Repetir senha", text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle("Cadastro")
    }
}

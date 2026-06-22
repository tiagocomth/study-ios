//
//  NewPasswordView.swift
//  Study
//

import SwiftUI

struct NewPasswordView: View {
    @StateObject var viewModel: NewPasswordViewModel

    var body: some View {
        VStack {
            Text("Nova senha")
                .font(.title)

            SecureField("Senha", text: $viewModel.passwordValue)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirmar senha", text: $viewModel.passwordConfirmationValue)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.updatePassword()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Alterar senha")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}

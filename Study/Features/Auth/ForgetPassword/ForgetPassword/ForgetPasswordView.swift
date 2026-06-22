//
//  ForgetPasswordView.swift
//  Study
//

import SwiftUI

struct ForgetPasswordView: View {
    @StateObject var viewModel: ForgetPasswordViewModel

    var body: some View {
        VStack {
            Text("Recuperar senha")
                .font(.title)

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.recoverPassword()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Recuperar")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}

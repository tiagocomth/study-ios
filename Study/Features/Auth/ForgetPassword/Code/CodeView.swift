//
//  CodeView.swift
//  Study
//

import SwiftUI

struct CodeView: View {
    @StateObject var viewModel: CodeViewModel

    var body: some View {
        VStack {
            Text("Código")
                .font(.title)

            TextField("Código", text: $viewModel.codeValue)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.validateCode()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Validar código")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canValidateCode || viewModel.isLoading)
        }
        .padding()
    }
}

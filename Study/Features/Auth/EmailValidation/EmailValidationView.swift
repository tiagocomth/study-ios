//
//  EmailValidationView.swift
//  Study
//

import SwiftUI

struct EmailValidationView: View {
    @StateObject var viewModel: EmailValidationViewModel
    @FocusState private var isCodeFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Valide seu e-mail")
                    .font(.largeTitle.bold())

                Text("Enviamos um código de \(EmailValidationViewModel.codeLength) dígitos para \(viewModel.email).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            codeInput

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                viewModel.validate()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Validar")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isCodeComplete || viewModel.isLoading)

            Button("Reenviar código") {
                viewModel.resendCode()
            }
            .font(.footnote)
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding()
        .onAppear { isCodeFieldFocused = true }
    }

    private var codeInput: some View {
        ZStack {
            // Campo real (invisível) que captura a digitação.
            TextField("", text: $viewModel.code)
                .focused($isCodeFieldFocused)
                .opacity(0.01)
                .frame(height: 1)

            // Representação visual em caixas.
            HStack(spacing: 12) {
                ForEach(0..<EmailValidationViewModel.codeLength, id: \.self) { index in
                    digitBox(at: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isCodeFieldFocused = true }
        }
    }

    private func digitBox(at index: Int) -> some View {
        let digits = Array(viewModel.code)
        let digit = index < digits.count ? String(digits[index]) : ""
        let isActive = index == digits.count && isCodeFieldFocused

        return Text(digit)
            .font(.title.bold())
            .frame(width: 48, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 2)
            )
    }
}

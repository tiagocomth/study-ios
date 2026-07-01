//
//  EmailValidationView.swift
//  Study
//

import SwiftUI

struct EmailValidationView: View {
    @StateObject var viewModel: EmailValidationViewModel
    @FocusState private var isCodeFieldFocused: Bool
    
    var body: some View {
        AuthResponsiveContainer(
            title: "Acabamos de enviar um código para o seu email",
            subtitle: "Confirme sua identidade",
            isHeaderCentered: true,
            onBack: { viewModel.navigateBack() }
        ) {
            validationForm
        }
        .navigationTitle("Validar E-mail")
        .onAppear { isCodeFieldFocused = true }
    }
}

private extension EmailValidationView {

    var validationForm: some View {
        VStack(alignment: .leading, spacing: 24) {
            codeInput

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(AppColors.secondaryPure)
                    .font(.footnote)
            }

            Button {
                viewModel.validate()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Continuar")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isCodeComplete || viewModel.isLoading)

            HStack {
                Spacer()
                Button("Reenviar código") {
                    viewModel.resendCode()
                }
                .buttonStyle(.link)
                Spacer()
            }

            Text("Dica: Caso não encontre o e-mail na sua caixa de entrada, verifique a pasta spam!")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
    }

    var codeInput: some View {
        ZStack {
            // Campo real (invisível) que captura a digitação.
            TextField("", text: $viewModel.code)
                .focused($isCodeFieldFocused)
                .opacity(0.01)
                .frame(height: 1)
                .focusEffectDisabled()

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

    func digitBox(at index: Int) -> some View {
        let digits = Array(viewModel.code)
        let digit = index < digits.count ? String(digits[index]) : ""
        let isActive = index == digits.count && isCodeFieldFocused

        return Text(digit)
            .font(.title2.bold())
            .frame(width: 48, height: 54)
            .background(Color.adaptiveTextFieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? Color.accentColor : Color.adaptiveSeparator, lineWidth: isActive ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

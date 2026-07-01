//
//  CodeView.swift
//  Study
//

import SwiftUI

struct CodeView: View {
    @StateObject var viewModel: CodeViewModel
    @FocusState private var isCodeFieldFocused: Bool

    var body: some View {
        AuthResponsiveContainer(
            title: "Acabamos de enviar um código para o seu email",
            subtitle: "Confirme sua identidade",
            isHeaderCentered: true,
            onBack: { viewModel.coordinator?.navigateBack() }
        ) {
            validationForm
        }
        .navigationTitle("Código")
        .onAppear { isCodeFieldFocused = true }
    }
}

private extension CodeView {

    var validationForm: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Spacer()
                codeInput
                Spacer()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(AppColors.secondaryPure)
                    .font(.footnote)
            }

            Button {
                viewModel.validateCode()
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
            .disabled(!viewModel.canValidateCode || viewModel.isLoading)
        }
    }

    var codeInput: some View {
        ZStack {
            // Campo real (invisível) que captura a digitação.
            TextField("", text: $viewModel.codeValue)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
                .focused($isCodeFieldFocused)
                .opacity(0.01)
                .frame(width: 1, height: 1)
                .offset(x: -1000, y: -1000)
                .focusEffectDisabled()

            // Representação visual em caixas.
            HStack(spacing: 8) {
                ForEach(0..<PasswordResetCode.length, id: \.self) { index in
                    digitBox(at: index)
                }
            }
            .frame(maxWidth: 328)
            .contentShape(Rectangle())
            .onTapGesture { isCodeFieldFocused = true }
        }
    }

    func digitBox(at index: Int) -> some View {
        let digits = Array(viewModel.codeValue)
        let digit = index < digits.count ? String(digits[index]) : ""
        let isActive = index == digits.count && isCodeFieldFocused

        return Text(digit)
            .font(.title2.bold())
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.adaptiveTextFieldBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? Color.accentColor : Color.adaptiveSeparator, lineWidth: isActive ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}



//
//  EmailValidationView.swift
//  Study
//

import SwiftUI

struct EmailValidationView: View {
    @StateObject var viewModel: EmailValidationViewModel
    @FocusState private var isCodeFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            leftPanel
            
            Divider()
            
            rightPanel
            
        }
        .navigationTitle("Validar E-mail")
        .onAppear { isCodeFieldFocused = true }
    }
}

private extension EmailValidationView {

    var leftPanel: some View {
        Image("login")
            .resizable()
            .scaledToFill()
            .clipped()
    }

    var rightPanel: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(alignment: .center, spacing: 30) {
                Text("Acabamos de enviar um código para o seu email")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text("Confirme sua identidade")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            validationForm

            Spacer()
        }
        .frame(maxWidth: 420)
        .padding(60)
    }

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

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

private extension Color {
    static var adaptiveTextFieldBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .secondarySystemBackground)
        #else
        return Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var adaptiveSeparator: Color {
        #if canImport(UIKit)
        return Color(uiColor: .separator)
        #else
        return Color(nsColor: .separatorColor)
        #endif
    }
}

//
//  AuthTextField.swift
//  Study
//
//  Created by Breno Marques on 26/06/26.
//

import SwiftUI

struct AuthTextField: View {

    let title: String
    let placeholder: String
    var isSecure = false

    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding? = nil

    init(
        title: String,
        placeholder: String,
        isSecure: Bool = false,
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.isSecure = isSecure
        self._text = text
        self.isFocused = isFocused
    }

    // Change magic numbers
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            field
                .textFieldStyle(.plain)
                .padding(.horizontal, 18)
                .frame(height: 56)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .textBackgroundColor))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary, lineWidth: 1.5)
                }
                .shadow(
                    color: .black.opacity(0.18),
                    radius: 5,
                    x: 0,
                    y: 3
                )
        }
    }

    @ViewBuilder
    private var field: some View {
        if isSecure {
            if let isFocused = isFocused {
                SecureField(placeholder, text: $text)
                    .focused(isFocused)
            } else {
                SecureField(placeholder, text: $text)
            }
        } else {
            if let isFocused = isFocused {
                TextField(placeholder, text: $text)
                    .focused(isFocused)
            } else {
                TextField(placeholder, text: $text)
            }
        }
    }
}

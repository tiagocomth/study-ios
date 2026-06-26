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
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }
}

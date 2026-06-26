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

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.headline)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(.roundedBorder)
            .controlSize(.large)

        }
    }
}

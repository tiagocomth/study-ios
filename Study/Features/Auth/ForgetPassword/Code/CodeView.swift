//
//  CodeView.swift
//  Study
//

import SwiftUI

struct CodeView: View { // NOTE: Essa tela seria usada para o EmailValidation e ForgetPassword, como que vai saber para qual tela tem q mandar?
    @StateObject var viewModel: CodeViewModel

    var body: some View {
        VStack {
            Text("Code")
                .font(.title)

            Button("New Password") {
                viewModel.navigateToNewPassword()
            }
        }
    }
}

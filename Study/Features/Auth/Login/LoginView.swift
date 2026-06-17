//
//  LoginView.swift
//  Study
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            Text("Login")
                .font(.title)

            Button("Forget Password") {
                viewModel.navigateToForgotPassword()
            }
        }
    }
}

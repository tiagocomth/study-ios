//
//  NewPasswordView.swift
//  Study
//

import SwiftUI

struct NewPasswordView: View {
    @StateObject var viewModel: NewPasswordViewModel

    var body: some View {
        VStack {
            Text("New Password")
                .font(.title)

            Button("Back to Root") {
                viewModel.navigateBackToRoot()
            }
        }
    }
}

//
//  ProfileView.swift
//  Study
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            Button("Mostrar Premium") {
                viewModel.presentPremium()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

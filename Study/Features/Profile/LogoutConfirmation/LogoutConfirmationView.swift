//
//  LogoutConfirmationView.swift
//  Study
//

import SwiftUI

struct LogoutConfirmationView: View {
    
    @StateObject var viewModel: LogoutConfirmationViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 45))
                .foregroundColor(.red)
            
            Text("Confirmar Logout")
                .font(.title3)
                .bold()
            
            Text("Você tem certeza de que deseja encerrar a sua sessão?")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 15) {
                Button("Cancelar") {
                    viewModel.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Sair") {
                    viewModel.logout()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 300, height: 220)
    }
}

#Preview {
    LogoutConfirmationView(viewModel: LogoutConfirmationViewModel(
        userSession: UserSessionService()
    ))
}

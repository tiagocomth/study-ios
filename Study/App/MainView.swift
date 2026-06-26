//
//  MainView.swift
//  Study
//

import SwiftUI

/// Tela principal exibida após o login. Placeholder — substituir pela navegação
/// real do app (tabs/coordinator principal) quando estiver pronta.
struct MainView: View {
    @ObservedObject var session: UserSessionService

    var body: some View {
        VStack(spacing: 16) {
            Text("Bem-vindo")
                .font(.largeTitle.bold())

            if let user = session.currentUser {
                Text(user.name)
                    .foregroundStyle(.secondary)
            }

            Button("Sair") {
                session.logout()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

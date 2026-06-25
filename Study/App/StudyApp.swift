//
//  StudyApp.swift
//  Study
//

import SwiftUI

@main
struct StudyApp: App {

    @State var appWorker = AppWorker()

    var body: some Scene {
        WindowGroup {
            RootView(appWorker: appWorker)
        }
    }
}

/// Decide o que mostrar com base na sessão: enquanto não há usuário logado,
/// exibe o fluxo de autenticação; após o login, abre a Explore (home) com sua
/// própria injeção via `GroupCoordinator`.
private struct RootView: View {
    let appWorker: AppWorker
    @ObservedObject private var session: UserSessionService

    init(appWorker: AppWorker) {
        self.appWorker = appWorker
        self.session = appWorker.userSessionService
    }

    var body: some View {
        Group {
            if session.isLoggedIn {
                CoordinateView(coordinator: appWorker.makeGroupCoordinator())
            } else {
                CoordinateView(coordinator: appWorker.makeAuthCoordinator())
            }
        }
        .task { session.restore() }
    }
}

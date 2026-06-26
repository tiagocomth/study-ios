//
//  StudyApp.swift
//  Study
//

import SwiftUI

@main
struct StudyApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @State var appWorker = AppWorker()

    var body: some Scene {
        WindowGroup {
            RootView(appWorker: appWorker)
                .onAppear {
                    appWorker.updateLifecycleState(AppLifecycleState(scenePhase))
                }
                .onChange(of: scenePhase) { _, newScenePhase in
                    appWorker.updateLifecycleState(AppLifecycleState(newScenePhase))
                }
        }
    }
}

/// Decide o que mostrar com base na sessão: enquanto não há usuário logado,
/// exibe o fluxo de autenticação; após o login, troca para a tela principal.
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
                MainView(session: session)
            } else {
                CoordinateView(coordinator: appWorker.makeAuthCoordinator())
                    
            }
        }
        .task { session.restore() }
    }
}

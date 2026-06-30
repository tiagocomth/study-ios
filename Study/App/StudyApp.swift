//
//  StudyApp.swift
//  Study
//

import SwiftUI
import SwiftData

@main
struct StudyApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @State var appWorker: AppWorker
    @State var container: ModelContainer

    init() {
        let container = try! ModelContainer(for: StoredStudyCategory.self)
        _container = .init(initialValue: container)
        _appWorker = .init(wrappedValue: .init(modelContainer: container))
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(appWorker: appWorker)
                .onAppear {
                    appWorker.updateLifecycleState(AppLifecycleState(scenePhase))
                }
                .onChange(of: scenePhase) { _, newScenePhase in
                    appWorker.updateLifecycleState(AppLifecycleState(newScenePhase))
                }
                .modelContainer(container)
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
                MainView(session: session, appWorker: appWorker)
            } else {
                CoordinateView(coordinator: appWorker.makeAuthCoordinator())
                    
            }
        }
    }
}

//
//  StudyApp.swift
//  Study
//

import SwiftUI
import SwiftData

@main
struct StudyApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @State private var appWorker: AppWorker

    init() {
        let modelContainer = StudyApp.makeContainer()
        _appWorker = State(initialValue: AppWorker(modelContainer: modelContainer))
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
                .modelContainer(appWorker.modelContainer)
                .frame(
                    minWidth: GlobalConfiguration.minimumWindowWidth,
                    minHeight: GlobalConfiguration.minimumWindowHeight
                )
        }
        .defaultSize(
            width: GlobalConfiguration.defaultWindowWidth,
            height: GlobalConfiguration.defaultWindowHeight
        )
        .windowResizability(.contentMinSize)
    }
}

extension StudyApp {
    static func makeContainer() -> ModelContainer {
        StudyModelContainerProvider.shared
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
                CoordinateView(coordinator: appWorker.makeStudySessionCoordinator())
            } else {
                CoordinateView(coordinator: appWorker.makeAuthCoordinator())
                    
            }
        }
    }
}

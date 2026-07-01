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
    @ObservedObject private var userSessionService: UserSessionService
    
    init() {
        let modelContainer = StudyApp.makeContainer()
        let worker = AppWorker(modelContainer: modelContainer)
        _appWorker = State(initialValue: worker)
        _userSessionService = .init(wrappedValue: worker.userSessionService)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userSessionService.isLoggedIn {
                    MainView(session: appWorker.userSessionService, appWorker: appWorker)
                } else {
                    CoordinateView(coordinator: appWorker.makeAuthCoordinator())
                }
            }
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

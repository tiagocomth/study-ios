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
            CoordinateView(coordinator: appWorker.makeAuthCoordinator())
                .onAppear {
                    appWorker.updateLifecycleState(AppLifecycleState(scenePhase))
                }
                .onChange(of: scenePhase) { _, newScenePhase in
                    appWorker.updateLifecycleState(AppLifecycleState(newScenePhase))
                }
        }
    }
}

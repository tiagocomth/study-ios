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
            CoordinateView(coordinator: appWorker.makeAuthCoordinator())
        }
    }
}

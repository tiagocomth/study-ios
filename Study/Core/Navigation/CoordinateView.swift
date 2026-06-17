//
//  CoordinateView.swift
//  Challenge13
//
//  Created by Caio Mandarino on 01/04/26.
//

import SwiftUI

struct CoordinateView<C: Coordinator>: View {
    var coordinator: C
    
    var body: some View {
        @Bindable var navigationController = coordinator.navigationController
        
        NavigationStack(path: $navigationController.navigationPath) {
            coordinator.rootView
                .navigationDestination(for: C.Router.self) { screen in
                    coordinator.coordinate(to: screen)
                }
                .sheetDestination(for: C.Router.self) { screen in
                    coordinator.coordinate(to: screen)
                }
        }
        .sheet(for: $navigationController.sheetPath)
    }
}


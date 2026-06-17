//
//  Coordinator.swift
//  Challenge13
//
//  Created by Caio Mandarino on 01/04/26.
//

import SwiftUI

protocol Coordinator {
    associatedtype RootView: View
    associatedtype DestinationView: View    
    associatedtype Router: Hashable & Identifiable
    
    var navigationController: NavigationController { get set }
    
    @MainActor @ViewBuilder var rootView: RootView { get }
    @MainActor @ViewBuilder func coordinate(to route: Router) -> DestinationView
}

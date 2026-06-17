//
//  NavigationController.swift
//  Challenge13
//
//  Created by Caio Mandarino on 01/04/26.
//

import SwiftUI

@MainActor
@Observable final class NavigationController {
    var navigationPath: NavigationPath = .init()
    var sheetPath: SheetPath = .init()
    
    func push<T: Hashable>(router: T) {
        navigationPath.append(router)
    }
    
    func pop() {
        guard !navigationPath.isEmpty else { return }
        
        navigationPath.removeLast()
    }
    
    func presentSheet<T: Hashable & Identifiable>(router: T, onDismiss: (() -> Void)? = nil ) {
        sheetPath.setSheet(router, onDismiss: onDismiss)
    }
    
    func dismissSheet() {
        sheetPath = .init()
    }
}

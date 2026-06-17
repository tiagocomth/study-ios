//
//  AppCoordinator.swift
//  Study
//

import SwiftUI

final class AppCoordinator { // MARK: Ter o estado se está logado ou não
    
    private let factory: AppFactory
    
    init(factory: AppFactory) {
        self.factory = factory
    }

    func makeAuthCoordinator() -> AuthCoordinator {
        factory.makeAuthCoordinator()
    }
}

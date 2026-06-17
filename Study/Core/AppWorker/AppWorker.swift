//
//  AppWorker.swift
//  Study
//
//  Created by Caio Mandarino on 17/06/26.
//

import Foundation

final class AppWorker {
    
    private let appCoordinator: AppCoordinator = .init(factory: .init())
    
    func makeAuthCoordinator() -> AuthCoordinator {
        return appCoordinator.makeAuthCoordinator()
    }
}

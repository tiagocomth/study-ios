//
//  ProfileFactory.swift
//  Study
//

import SwiftUI

final class ProfileFactory {
    // TODO: cria as Views e gerencia o ciclo de vida dos ViewModels
    weak var profileCoordinator: ProfileCoordinator?
    
    private let apiClient: APIClientProtocol
    private let userSession: UserSessionProtocol
    
    init(apiClient: APIClientProtocol, userSession: UserSessionProtocol) {
        self.apiClient = apiClient
        self.userSession = userSession
    }
}

// MARK: Internal
extension ProfileFactory {
    private func makeProfileVM() -> ProfileViewModel {
        let worker = ProfileWorker()
        let vm = ProfileViewModel(worker: worker)
        vm.coordinator = profileCoordinator
        return vm
    }
}

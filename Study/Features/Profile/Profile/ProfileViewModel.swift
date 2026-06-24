//
//  ProfileViewModel.swift
//  Study
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    
    weak var coordinator: ProfileCoordinatorProtocol?
    private let worker: ProfileWorkerProtocol

    init(worker: ProfileWorkerProtocol) {
        self.worker = worker
    }

    func presentPremium() {
        coordinator?.presentPremium()
    }

    func showLogoutConfirmation() {
        coordinator?.presentLogoutConfirmation()
    }
}

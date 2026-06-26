//
//  ProfileViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    weak var coordinator: ProfileCoordinatorProtocol?
    private let worker: ProfileWorkerProtocol

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var profile: Profile? = nil

    init(worker: ProfileWorkerProtocol) {
        self.worker = worker
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await worker.getMyProfile()
            self.profile = result
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func presentPremium() {
        coordinator?.presentPremium()
    }

    func showLogoutConfirmation() {
        coordinator?.presentLogoutConfirmation()
    }
}

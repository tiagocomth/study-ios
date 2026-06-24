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
    @Published var profile: GetProfileResponse? = nil
    @Published var sessions: [Session] = []

    init(worker: ProfileWorkerProtocol) {
        self.worker = worker
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let profileTask = worker.getMyProfile()
            async let sessionsTask = worker.getSessions()

            let (profileResult, sessionsResult) = try await (profileTask, sessionsTask)

            self.profile = profileResult.data
            self.sessions = sessionsResult.sessions.map { $0.toDomain() }
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

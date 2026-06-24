//
//  ProfileFactory.swift
//  Study
//

import SwiftUI

final class ProfileFactory {
    
    weak var profileCoordinator: ProfileCoordinator?
    
    private let apiClient: APIClientProtocol
    private let userSession: UserSessionProtocol
    private let paymentService: PaymentProtocol
    
    init(apiClient: APIClientProtocol, userSession: UserSessionProtocol, paymentService: PaymentProtocol) {
        self.apiClient = apiClient
        self.userSession = userSession
        self.paymentService = paymentService
    }
    
    func makeProfileView() -> some View {
        let vm = makeProfileVM()
        return ProfileView(viewModel: vm)
    }
    
    func makePremiumView() -> some View {
        let worker = PremiumWorker(paymentService: paymentService, userSession: userSession)
        let vm = PremiumViewModel(worker: worker)
        vm.coordinator = profileCoordinator
        return PremiumView(viewModel: vm)
    }
    
    func makeLogoutConfirmationView() -> some View {
        let vm = LogoutConfirmationViewModel(userSession: userSession)
        vm.coordinator = profileCoordinator
        return LogoutConfirmationView(viewModel: vm)
    }
    
    func makeEditProfileView() -> some View {
        let service = ProfileService(apiClient: apiClient)
        let worker = EditProfileWorker(service: service, userSession: userSession)
        let vm = EditProfileViewModel(worker: worker)
        vm.coordinator = profileCoordinator
        return EditProfileView(viewModel: vm)
    }
}

// MARK: - Internal
extension ProfileFactory {
    private func makeProfileVM() -> ProfileViewModel {
        let service = ProfileService(apiClient: apiClient)
        let worker = ProfileWorker(service: service, userSession: userSession)
        let vm = ProfileViewModel(worker: worker)
        vm.coordinator = profileCoordinator
        return vm
    }
}

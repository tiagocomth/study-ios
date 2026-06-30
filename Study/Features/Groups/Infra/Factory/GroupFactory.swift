//
//  GroupFactory.swift
//  Study
//

import SwiftUI

final class GroupFactory {
    
    weak var groupCoordinator: GroupCoordinator?
    
    private let apiClient: APIClientProtocol
    private let userSession: UserSessionProtocol
    
    init(apiClient: APIClientProtocol, userSession: UserSessionProtocol) {
        self.apiClient = apiClient
        self.userSession = userSession
    }
    
    func makeExploreGroupsView() -> some View {
        let service = ExploreGroupsService()
        let worker = ExploreGroupsWorker(service: service)
        let vm = ExploreGroupsViewModel(worker: worker)
        vm.coordinator = groupCoordinator
        return ExploreGroupsView(viewModel: vm)
    }
}

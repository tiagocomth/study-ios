//
//  GroupFactory.swift
//  Study
//

import SwiftUI

final class GroupFactory {

    weak var groupCoordinator: GroupCoordinator?
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func makeExploreGroupsView() -> some View {
        let viewModel = makeExploreGroupsVM()
        return ExploreGroupsView(viewModel: viewModel)
    }

    func makeCreateGroupView() -> some View {
        let viewModel = makeCreateGroupVM()
        return CreateGroupView(viewModel: viewModel)
    }
}

// MARK: - Internal
extension GroupFactory {
    private func makeExploreGroupsVM() -> ExploreGroupsViewModel {
        let service = ExploreGroupsService(apiClient: apiClient)
        let worker = ExploreGroupsWorker(service: service)
        let viewModel = ExploreGroupsViewModel(worker: worker)

        viewModel.coordinator = groupCoordinator
        // Guarda a VM da raiz para recarregar a lista após criar um grupo.
        groupCoordinator?.exploreGroupsViewModel = viewModel
        return viewModel
    }

    private func makeCreateGroupVM() -> CreateGroupViewModel {
        let service = CreateGroupService(apiClient: apiClient)
        let worker = CreateGroupWorker(service: service)
        let viewModel = CreateGroupViewModel(worker: worker)

        viewModel.coordinator = groupCoordinator
        return viewModel
    }
}

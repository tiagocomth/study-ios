//
//  GroupFactory.swift
//  Study
//

import SwiftUI

final class GroupFactory {

    weak var groupCoordinator: GroupCoordinator?
    private let apiClient: APIClientProtocol
    private let userSession: UserSessionProtocol

    /// Mantém uma única instância da VM da Explore. A `rootView` do coordinator é
    /// uma computed property e pode ser acessada várias vezes; sem cache, cada
    /// acesso criava uma VM nova, e o `reload()` acabava chamando uma VM órfã (não
    /// a que o `@StateObject` da tela está exibindo).
    private var exploreGroupsViewModel: ExploreGroupsViewModel?

    init(apiClient: APIClientProtocol, userSession: UserSessionProtocol) {
        self.apiClient = apiClient
        self.userSession = userSession
    }

    func makeExploreGroupsView() -> some View {
        let viewModel = makeExploreGroupsVM()
        return ExploreGroupsView(viewModel: viewModel)
    }

    func makeCreateGroupView() -> some View {
        let viewModel = makeCreateGroupVM()
        return CreateGroupView(viewModel: viewModel)
    }

    func makeJoinGroupView(group: StudyGroup) -> some View {
        let viewModel = makeJoinGroupVM(group: group)
        return JoinGroupView(viewModel: viewModel)
    }

    func makeGroupDetailsView(group: StudyGroup) -> some View {
        let viewModel = makeGroupDetailsVM(group: group)
        return GroupDetailsView(viewModel: viewModel)
    }
}

// MARK: - Internal
extension GroupFactory {
    private func makeExploreGroupsVM() -> ExploreGroupsViewModel {
        // Reaproveita a instância já criada para manter a mesma VM que a tela exibe.
        if let viewModel = exploreGroupsViewModel {
            return viewModel
        }

        let service = ExploreGroupsService(apiClient: apiClient)
        let worker = ExploreGroupsWorker(service: service, userSession: userSession)
        let viewModel = ExploreGroupsViewModel(worker: worker)

        viewModel.coordinator = groupCoordinator
        exploreGroupsViewModel = viewModel
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

    private func makeJoinGroupVM(group: StudyGroup) -> JoinGroupViewModel {
        let service = JoinGroupPasswordService(apiClient: apiClient)
        let worker = JoinGroupPasswordWorker(service: service)
        let viewModel = JoinGroupViewModel(group: group, worker: worker)

        viewModel.coordinator = groupCoordinator
        return viewModel
    }

    private func makeGroupDetailsVM(group: StudyGroup) -> GroupDetailsViewModel {
        let service = GroupService(apiClient: apiClient)
        let worker = GroupDetailsWorker(service: service)
        let viewModel = GroupDetailsViewModel(group: group, worker: worker)

        viewModel.coordinator = groupCoordinator
        return viewModel
    }
}

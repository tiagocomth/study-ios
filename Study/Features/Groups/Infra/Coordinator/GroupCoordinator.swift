//
//  GroupCoordinator.swift
//  Study
//

import SwiftUI

final class GroupCoordinator: Coordinator {

    var navigationController: NavigationController = .init()
    private let factory: GroupFactory

    /// Referência fraca à VM da raiz (Explore), para recarregar a lista
    /// sempre que o sheet de criação fechar.
    weak var exploreGroupsViewModel: ExploreGroupsViewModel?

    init(factory: GroupFactory) {
        self.factory = factory
        factory.groupCoordinator = self
    }

    var rootView: some View {
        factory.makeExploreGroupsView()
    }

    func coordinate(to route: GroupRouter) -> some View {
        switch route {
        case .createGroup:
            factory.makeCreateGroupView()
        }
    }

    // MARK: - Navegação
    func presentCreateGroup() {
        // Ao fechar o sheet (criar, cancelar ou arrastar), recarrega a Explore
        // para a lista vir sempre atualizada com os dados do backend.
        navigationController.presentSheet(router: GroupRouter.createGroup) { [weak self] in
            self?.exploreGroupsViewModel?.reload()
        }
    }

    func dismissCreateGroup() {
        navigationController.dismissSheet()
    }
}

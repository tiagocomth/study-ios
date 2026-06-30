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

    @ViewBuilder
    func coordinate(to route: GroupRouter) -> some View {
        switch route {
        case .createGroup:
            factory.makeCreateGroupView()
        case .joinGroup(let group):
            factory.makeJoinGroupView(group: group)
        case .groupDetails(let group):
            factory.makeGroupDetailsView(group: group)
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

    /// Abre o pop-up de entrada (sheet) para o grupo tocado na Explore.
    /// Ao fechar (entrar, cancelar ou arrastar), recarrega a Explore.
    func presentJoinGroup(group: StudyGroup) {
        navigationController.presentSheet(router: GroupRouter.joinGroup(group)) { [weak self] in
            self?.exploreGroupsViewModel?.reload()
        }
    }

    func dismissJoinGroup() {
        navigationController.dismissSheet()
    }

    /// Entra direto na tela de membros (usado quando o usuário já é membro,
    /// ex.: dono do grupo) sem passar pelo pop-up.
    func showGroupDetails(group: StudyGroup) {
        navigationController.push(router: GroupRouter.groupDetails(group))
    }

    /// Concluiu a entrada (ou criação): fecha o sheet — cujo `onDismiss`
    /// recarrega a Explore — e navega para a tela de membros.
    func completeJoin(group: StudyGroup) {
        navigationController.dismissSheet()
        navigationController.push(router: GroupRouter.groupDetails(group))
    }

    func pop() {
        navigationController.pop()
    }
}

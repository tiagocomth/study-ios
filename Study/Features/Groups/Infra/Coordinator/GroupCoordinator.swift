//
//  GroupCoordinator.swift
//  Study
//

import SwiftUI

final class GroupCoordinator: Coordinator {
    var navigationController: NavigationController = .init()
    private let factory: GroupFactory

    init(factory: GroupFactory) {
        self.factory = factory
        factory.groupCoordinator = self
    }

    var rootView: some View {
        factory.makeExploreGroupsView()
    }

    func coordinate(to route: GroupRouter) -> some View {
        switch route {
        case .none:
            EmptyView()
        }
    }
}

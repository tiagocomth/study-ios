//
//  StudySessionCoordinator.swift
//  Study
//

import SwiftUI

enum StudySessionRouter: Hashable, Identifiable {
    var id: Self { self }
    
    case none
}

final class StudySessionCoordinator: Coordinator {
    var navigationController: NavigationController = .init()
    private let factory: StudySessionFactory

    init(factory: StudySessionFactory) {
        self.factory = factory
        factory.coordinator = self
    }

    var rootView: some View {
        factory.makeStudySessionView()
    }

    func coordinate(to route: StudySessionRouter) -> some View {
        switch route {
        case .none:
            EmptyView()
        }
    }
}

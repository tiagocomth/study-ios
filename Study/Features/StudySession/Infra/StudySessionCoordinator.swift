//
//  StudySessionCoordinator.swift
//  Study
//

import SwiftUI

protocol StudySessionCoordinatorProtocol: AnyObject {
    func presentCreateCategory()
}

protocol StudySessionCategoryFormCoordinatorProtocol: AnyObject {
    func dismissCreateCategory()
}

enum StudySessionRouter: Hashable, Identifiable {
    var id: Self { self }
    
    case createCategory
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
        case .createCategory:
            factory.makeCategoryFormView()
        }
    }
}

extension StudySessionCoordinator: StudySessionCoordinatorProtocol {
    func presentCreateCategory() {
        navigationController.presentSheet(router: StudySessionRouter.createCategory)
    }
}

extension StudySessionCoordinator: StudySessionCategoryFormCoordinatorProtocol {
    func dismissCreateCategory() {
        navigationController.dismissSheet()
    }
}

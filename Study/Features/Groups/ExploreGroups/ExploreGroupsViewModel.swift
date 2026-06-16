//
//  ExploreGroupsViewModel.swift
//  Study
//

import Foundation
import Combine

final class ExploreGroupsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: ExploreGroupsWorker

    init(worker: ExploreGroupsWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação — usar debounce na busca
}

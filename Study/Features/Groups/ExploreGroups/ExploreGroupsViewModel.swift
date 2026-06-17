//
//  ExploreGroupsViewModel.swift
//  Study
//

import Foundation
import Combine

final class ExploreGroupsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: ExploreGroupsWorkerProtocol

    init(worker: ExploreGroupsWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação — usar debounce na busca
}

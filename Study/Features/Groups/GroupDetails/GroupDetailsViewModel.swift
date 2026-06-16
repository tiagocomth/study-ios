//
//  GroupDetailsViewModel.swift
//  Study
//

import Foundation
import Combine

final class GroupDetailsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: GroupDetailsWorker

    init(worker: GroupDetailsWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

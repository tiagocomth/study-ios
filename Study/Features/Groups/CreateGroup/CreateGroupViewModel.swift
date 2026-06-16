//
//  CreateGroupViewModel.swift
//  Study
//

import Foundation
import Combine

final class CreateGroupViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: CreateGroupWorker

    init(worker: CreateGroupWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

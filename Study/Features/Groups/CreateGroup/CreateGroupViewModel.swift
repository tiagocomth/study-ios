//
//  CreateGroupViewModel.swift
//  Study
//

import Foundation
import Combine

final class CreateGroupViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: CreateGroupWorkerProtocol

    init(worker: CreateGroupWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

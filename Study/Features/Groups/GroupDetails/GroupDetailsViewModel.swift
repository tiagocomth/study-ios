//
//  GroupDetailsViewModel.swift
//  Study
//

import Foundation
import Combine

final class GroupDetailsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: GroupDetailsWorkerProtocol

    init(worker: GroupDetailsWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

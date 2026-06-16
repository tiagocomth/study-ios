//
//  GroupConfigViewModel.swift
//  Study
//

import Foundation
import Combine

final class GroupConfigViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: GroupConfigWorkerProtocol

    init(worker: GroupConfigWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

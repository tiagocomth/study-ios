//
//  GroupConfigViewModel.swift
//  Study
//

import Foundation
import Combine

final class GroupConfigViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: GroupConfigWorker

    init(worker: GroupConfigWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

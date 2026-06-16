//
//  GroupsViewModel.swift
//  Study
//

import Foundation
import Combine

final class GroupsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: GroupsWorker

    init(worker: GroupsWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

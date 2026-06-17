//
//  GroupsViewModel.swift
//  Study
//

import Foundation
import Combine

final class GroupsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: GroupsWorkerProtocol

    init(worker: GroupsWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

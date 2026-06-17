//
//  JoinGroupViewModel.swift
//  Study
//

import Foundation
import Combine

final class JoinGroupViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: JoinGroupPasswordWorkerProtocol

    init(worker: JoinGroupPasswordWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

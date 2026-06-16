//
//  ProfileViewModel.swift
//  Study
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    weak var coordinator: ProfileCoordinator?
    private let worker: ProfileWorkerProtocol

    init(worker: ProfileWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

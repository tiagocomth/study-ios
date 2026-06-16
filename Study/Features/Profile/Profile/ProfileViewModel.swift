//
//  ProfileViewModel.swift
//  Study
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    weak var coordinator: ProfileCoordinator?
    private let worker: ProfileWorker

    init(worker: ProfileWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

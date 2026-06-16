//
//  RegisterViewModel.swift
//  Study
//

import Foundation
import Combine

final class RegisterViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: RegisterWorker

    init(worker: RegisterWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

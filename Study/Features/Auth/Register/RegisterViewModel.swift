//
//  RegisterViewModel.swift
//  Study
//

import Foundation
import Combine

final class RegisterViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: RegisterWorkerProtocol

    init(worker: RegisterWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

//
//  NewPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class NewPasswordViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: NewPasswordWorkerProtocol

    init(worker: NewPasswordWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

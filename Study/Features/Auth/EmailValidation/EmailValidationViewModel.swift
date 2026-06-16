//
//  EmailValidationViewModel.swift
//  Study
//

import Foundation
import Combine

final class EmailValidationViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: EmailValidationWorkerProtocol

    init(worker: EmailValidationWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

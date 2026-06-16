//
//  ForgetPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class ForgetPasswordViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: ForgetPasswordWorkerProtocol

    init(worker: ForgetPasswordWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

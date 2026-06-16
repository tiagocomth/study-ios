//
//  LoginViewModel.swift
//  Study
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: LoginWorkerProtocol

    init(worker: LoginWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

//
//  LoginViewModel.swift
//  Study
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: LoginWorker

    init(worker: LoginWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

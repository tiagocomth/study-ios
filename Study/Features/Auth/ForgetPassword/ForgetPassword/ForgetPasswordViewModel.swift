//
//  ForgetPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class ForgetPasswordViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: ForgetPasswordWorker

    init(worker: ForgetPasswordWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

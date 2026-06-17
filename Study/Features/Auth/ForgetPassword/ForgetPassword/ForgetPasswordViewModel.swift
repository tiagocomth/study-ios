//
//  ForgetPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class ForgetPasswordViewModel: ObservableObject {
    weak var coordinator: ForgetPasswordCoordinatorProtocol?
    private let worker: ForgetPasswordWorkerProtocol

    init(worker: ForgetPasswordWorkerProtocol) {
        self.worker = worker
    }

    func navigateToCode() {
        coordinator?.navigateToCode()
    }
}

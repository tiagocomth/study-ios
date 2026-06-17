//
//  NewPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class NewPasswordViewModel: ObservableObject {
    weak var coordinator: NewPasswordCoordinatorProtocol?
    private let worker: NewPasswordWorkerProtocol

    init(worker: NewPasswordWorkerProtocol) {
        self.worker = worker
    }

    func navigateBackToRoot() {
        coordinator?.navigateBackToRoot()
    }
}

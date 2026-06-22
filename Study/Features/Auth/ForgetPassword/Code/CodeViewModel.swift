//
//  CodeViewModel.swift
//  Study
//

import Foundation
import Combine

final class CodeViewModel: ObservableObject {
    weak var coordinator: CodeCoordinatorProtocol?
    private let worker: CodeWorkerProtocol

    init(worker: CodeWorkerProtocol) {
        self.worker = worker
    }

    func navigateToNewPassword() {
        coordinator?.navigateToNewPassword()
    }
}

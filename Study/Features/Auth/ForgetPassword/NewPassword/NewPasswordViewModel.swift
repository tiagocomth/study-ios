//
//  NewPasswordViewModel.swift
//  Study
//

import Foundation
import Combine

final class NewPasswordViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: NewPasswordWorker

    init(worker: NewPasswordWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

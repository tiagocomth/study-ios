//
//  CodeViewModel.swift
//  Study
//

import Foundation
import Combine

final class CodeViewModel: ObservableObject {
    weak var coordinator: AuthCoordinator?
    private let worker: CodeWorkerProtocol

    init(worker: CodeWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

//
//  MetricsViewModel.swift
//  Study
//

import Foundation
import Combine

final class MetricsViewModel: ObservableObject {
    weak var coordinator: MetricsCoordinator?
    private let worker: MetricsWorkerProtocol

    init(worker: MetricsWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

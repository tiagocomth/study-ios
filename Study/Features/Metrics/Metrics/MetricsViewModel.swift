//
//  MetricsViewModel.swift
//  Study
//

import Foundation
import Combine

final class MetricsViewModel: ObservableObject {
    weak var coordinator: MetricsCoordinator?
    private let worker: MetricsWorker

    init(worker: MetricsWorker) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

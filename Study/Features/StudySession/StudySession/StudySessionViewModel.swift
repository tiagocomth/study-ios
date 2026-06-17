//
//  StudySessionViewModel.swift
//  Study
//

import Foundation
import Combine

final class StudySessionViewModel: ObservableObject {
    weak var coordinator: StudySessionCoordinator?
    private let worker: StudySessionWorkerProtocol

    init(worker: StudySessionWorkerProtocol) {
        self.worker = worker
    }

    // TODO: lógica de apresentação
}

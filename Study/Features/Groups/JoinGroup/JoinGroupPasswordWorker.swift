//
//  JoinGroupPasswordWorker.swift
//  Study
//

import Foundation

protocol JoinGroupPasswordWorkerProtocol {
}

final class JoinGroupPasswordWorker: JoinGroupPasswordWorkerProtocol {
    private let service: JoinGroupPasswordServiceProtocol

    init(service: JoinGroupPasswordServiceProtocol) {
        self.service = service
    }

    // TODO: ações — func confirmPassword(for:) -> Bool
}

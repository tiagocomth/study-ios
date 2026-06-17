//
//  RegisterWorker.swift
//  Study
//

import Foundation

protocol RegisterWorkerProtocol {
}

final class RegisterWorker: RegisterWorkerProtocol {
    private let service: RegisterServiceProtocol

    init(service: RegisterServiceProtocol) {
        self.service = service
    }

    // TODO: ações
}

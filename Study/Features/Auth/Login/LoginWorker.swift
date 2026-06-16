//
//  LoginWorker.swift
//  Study
//

import Foundation

protocol LoginWorkerProtocol {
}

final class LoginWorker: LoginWorkerProtocol {
    private let service: LoginServiceProtocol

    init(service: LoginServiceProtocol) {
        self.service = service
    }

    // TODO: ações
}

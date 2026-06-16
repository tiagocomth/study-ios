//
//  NewPasswordWorker.swift
//  Study
//

import Foundation

protocol NewPasswordWorkerProtocol {
}

final class NewPasswordWorker: NewPasswordWorkerProtocol {
    private let service: NewPasswordServiceProtocol

    init(service: NewPasswordServiceProtocol) {
        self.service = service
    }

    // TODO: ações
}

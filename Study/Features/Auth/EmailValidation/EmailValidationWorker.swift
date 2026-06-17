//
//  EmailValidationWorker.swift
//  Study
//

import Foundation

protocol EmailValidationWorkerProtocol {
}

final class EmailValidationWorker: EmailValidationWorkerProtocol {
    private let service: EmailValidationServiceProtocol

    init(service: EmailValidationServiceProtocol) {
        self.service = service
    }

    // TODO: ações
}

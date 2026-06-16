//
//  ForgetPasswordWorker.swift
//  Study
//

import Foundation

protocol ForgetPasswordWorkerProtocol {
}

final class ForgetPasswordWorker: ForgetPasswordWorkerProtocol {
    private let service: ForgetPasswordServiceProtocol

    init(service: ForgetPasswordServiceProtocol) {
        self.service = service
    }

    // TODO: ações
}

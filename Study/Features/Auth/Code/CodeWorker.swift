//
//  CodeWorker.swift
//  Study
//

import Foundation

protocol CodeWorkerProtocol {
}

final class CodeWorker: CodeWorkerProtocol {
    private let service: CodeServiceProtocol

    init(service: CodeServiceProtocol) {
        self.service = service
    }

    // TODO: ações
}

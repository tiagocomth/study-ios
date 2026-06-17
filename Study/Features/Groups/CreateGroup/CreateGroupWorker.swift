//
//  CreateGroupWorker.swift
//  Study
//

import Foundation

protocol CreateGroupWorkerProtocol {
}

final class CreateGroupWorker: CreateGroupWorkerProtocol {
    private let service: CreateGroupServiceProtocol

    init(service: CreateGroupServiceProtocol) {
        self.service = service
    }

    // TODO: ações — validar qtd membros, max grupos, premium
}

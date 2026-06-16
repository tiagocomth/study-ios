//
//  GroupConfigWorker.swift
//  Study
//

import Foundation

protocol GroupConfigWorkerProtocol {
}

final class GroupConfigWorker: GroupConfigWorkerProtocol {
    private let service: GroupConfigServiceProtocol

    init(service: GroupConfigServiceProtocol) {
        self.service = service
    }

    // TODO: ações — updateGroup PATCH, removeUser DELETE
}

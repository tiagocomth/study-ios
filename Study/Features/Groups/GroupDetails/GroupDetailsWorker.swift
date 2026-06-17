//
//  GroupDetailsWorker.swift
//  Study
//

import Foundation

protocol GroupDetailsWorkerProtocol {
}

final class GroupDetailsWorker: GroupDetailsWorkerProtocol {
    private let service: GroupServiceProtocol

    init(service: GroupServiceProtocol) {
        self.service = service
    }

    // TODO: ações — getGroupById() -> Group
}

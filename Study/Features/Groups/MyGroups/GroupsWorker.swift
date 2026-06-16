//
//  GroupsWorker.swift
//  Study
//

import Foundation

protocol GroupsWorkerProtocol {
}

final class GroupsWorker: GroupsWorkerProtocol {
    private let service: GroupsServiceProtocol

    init(service: GroupsServiceProtocol) {
        self.service = service
    }

    // TODO: ações — func myGroups(page) -> GET /groups/my
}

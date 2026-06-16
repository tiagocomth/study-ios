//
//  ExploreGroupsWorker.swift
//  Study
//

import Foundation

protocol ExploreGroupsWorkerProtocol {
}

final class ExploreGroupsWorker: ExploreGroupsWorkerProtocol {
    private let service: ExploreGroupsServiceProtocol

    init(service: ExploreGroupsServiceProtocol) {
        self.service = service
    }

    // TODO: ações — func exploreGroups(page, name?) -> GET /groups?filter=name&page=1
}

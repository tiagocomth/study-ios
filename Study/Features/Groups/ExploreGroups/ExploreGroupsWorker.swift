//
//  ExploreGroupsWorker.swift
//  Study
//

import Foundation

protocol ExploreGroupsWorkerProtocol {
    func exploreGroups(filter: String?, isPrivate: Bool?, page: Int) async throws -> GroupsPage
}

final class ExploreGroupsWorker: ExploreGroupsWorkerProtocol {
    private let service: ExploreGroupsServiceProtocol

    init(service: ExploreGroupsServiceProtocol) {
        self.service = service
    }

    func exploreGroups(filter: String?, isPrivate: Bool?, page: Int) async throws -> GroupsPage {
        try await service.fetchGroups(filter: filter, isPrivate: isPrivate, page: page)
    }
}

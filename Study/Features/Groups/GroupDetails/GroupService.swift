//
//  GroupService.swift
//  Study
//

import Foundation

protocol GroupServiceProtocol {
    /// Estado ao vivo do grupo (membros ativos/inativos).
    /// `GET /groups/{id}/members/active`.
    func fetchActiveMembers(groupId: String) async throws(NetworkError) -> GroupLiveStatus
}

final class GroupService: GroupServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchActiveMembers(groupId: String) async throws(NetworkError) -> GroupLiveStatus {
        let endpoint = GroupEndpoint.activeMembers(id: groupId)
        let response: ActiveMembersResponseDTO = try await apiClient.request(endpoint)
        return response.toDomain()
    }
}

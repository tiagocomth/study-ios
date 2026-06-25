//
//  CreateGroupService.swift
//  Study
//

import Foundation

protocol CreateGroupServiceProtocol {
    /// Cria um grupo no backend e retorna o grupo criado. `POST /groups`.
    /// O backend deriva `isPrivate` da presença de `password` — por isso o request
    /// não envia `isPrivate`.
    func createGroup(name: String, description: String?, maxMembers: Int?, password: String?) async throws(NetworkError) -> StudyGroup
}

final class CreateGroupService: CreateGroupServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func createGroup(name: String, description: String?, maxMembers: Int?, password: String?) async throws(NetworkError) -> StudyGroup {
        let endpoint = GroupEndpoint.create(
            CreateGroupRequestDTO(name: name, description: description, maxMembers: maxMembers, password: password)
        )
        let response: GroupActionResponseDTO = try await apiClient.request(endpoint)
        return response.data.toDomain()
    }
}

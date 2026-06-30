//
//  JoinGroupPasswordService.swift
//  Study
//

import Foundation

protocol JoinGroupPasswordServiceProtocol {
    /// Vincula o usuário autenticado ao grupo. `POST /groups/{id}/join`.
    /// `password` vai apenas para grupos privados (nil em públicos).
    func join(groupId: String, password: String?) async throws(NetworkError)
}

final class JoinGroupPasswordService: JoinGroupPasswordServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func join(groupId: String, password: String?) async throws(NetworkError) {
        let endpoint = GroupEndpoint.join(id: groupId, JoinGroupRequestDTO(password: password))
        // A resposta (`{ message }`) não é usada na UI; só confirma o sucesso.
        let _: JoinGroupResponseDTO = try await apiClient.request(endpoint)
    }
}

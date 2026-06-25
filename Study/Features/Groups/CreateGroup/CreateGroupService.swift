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
        let endpoint = CreateGroupEndpoint.create(
            CreateGroupRequest(name: name, description: description, maxMembers: maxMembers, password: password)
        )
        let response: GroupActionResponse = try await apiClient.request(endpoint)
        return response.data.toDomain()
    }
}
//NEXT1: isso aqui n pode ficar aqui trocar essa struct para o lugar de scructs, mesma coisa para o endpoint siga o mesmo padrão que o auth usa crie um só para a feature de grupos
extension CreateGroupService {
    /// Espelha `CreateGroupDto` — `{ name, description?, maxMembers?, password? }`.
    /// `isPrivate` não entra no body; o backend infere pela presença de `password`.
    private struct CreateGroupRequest: Encodable {
        let name: String
        let description: String?
        let maxMembers: Int?
        let password: String?
    }

    /// Espelha `GroupActionResponseDto` (`{ message, data }`).
    private struct GroupActionResponse: Decodable {
        let message: String?
        let data: GroupDTO
    }

    private enum CreateGroupEndpoint: Endpoint {
        case create(CreateGroupRequest)

        var path: String {
            switch self {
            case .create:
                "/groups"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .create:
                .post
            }
        }

        var task: HTTPTask {
            switch self {
            case .create(let request):
                .requestJSONBody(request)
            }
        }

        var headers: Headers? {
            nil
        }
    }
}

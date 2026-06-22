//
//  NewPasswordService.swift
//  Study
//

import Foundation

protocol NewPasswordServiceProtocol {
}

final class NewPasswordService: NewPasswordServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // TODO: chamadas de baixo nível usando a session recebida do worker no request de nova senha.
}

//
//  ExploreGroupsWorker.swift
//  Study
//

import Foundation

protocol ExploreGroupsWorkerProtocol {
    /// Busca grupos aplicando texto e filtro de privacidade. A normalização do
    /// termo e a tradução do filtro para o contrato da API ficam aqui.
    func exploreGroups(searchText: String, privacy: GroupPrivacyFilter, page: Int) async throws -> GroupsPage

    /// Ainda há páginas a carregar para o filtro atual?
    func canLoadMore(loaded: Int, total: Int) -> Bool

    /// Deve carregar a próxima página ao exibir o item no índice `index`?
    func shouldLoadMore(at index: Int, loaded: Int, total: Int) -> Bool
}

final class ExploreGroupsWorker: ExploreGroupsWorkerProtocol {
    private let service: ExploreGroupsServiceProtocol

    /// Quantas linhas antes do fim disparam o carregamento da próxima página.
    private let prefetchThreshold = 3

    init(service: ExploreGroupsServiceProtocol) {
        self.service = service
    }

    func exploreGroups(searchText: String, privacy: GroupPrivacyFilter, page: Int) async throws -> GroupsPage {
        try await service.fetchGroups(
            filter: normalize(searchText: searchText),
            isPrivate: apiIsPrivate(for: privacy),
            page: page
        )
    }

    func canLoadMore(loaded: Int, total: Int) -> Bool {
        loaded < total
    }

    func shouldLoadMore(at index: Int, loaded: Int, total: Int) -> Bool {
        guard canLoadMore(loaded: loaded, total: total) else { return false }
        return index >= loaded - prefetchThreshold
    }

    // MARK: - Regras

    /// Normaliza o termo digitado: remove espaços e devolve `nil` quando vazio.
    private func normalize(searchText: String) -> String? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Traduz o filtro da tela para o parâmetro da API
    /// (`nil` = todos, `false` = públicos, `true` = privados).
    private func apiIsPrivate(for privacy: GroupPrivacyFilter) -> Bool? {
        switch privacy {
        case .all: nil
        case .public: false
        case .private: true
        }
    }
}

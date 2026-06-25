//
//  ExploreGroupsWorker.swift
//  Study
//

import Foundation

protocol ExploreGroupsWorkerProtocol {
    func exploreGroups(filter: String?, isPrivate: Bool?, page: Int) async throws -> GroupsPage

    /// Normaliza o termo digitado: remove espaços e devolve `nil` quando vazio.
    func normalize(searchText: String) -> String?

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

    func exploreGroups(filter: String?, isPrivate: Bool?, page: Int) async throws -> GroupsPage {
        try await service.fetchGroups(filter: filter, isPrivate: isPrivate, page: page)
    }

    func normalize(searchText: String) -> String? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func canLoadMore(loaded: Int, total: Int) -> Bool {
        loaded < total
    }

    func shouldLoadMore(at index: Int, loaded: Int, total: Int) -> Bool {
        guard canLoadMore(loaded: loaded, total: total) else { return false }
        return index >= loaded - prefetchThreshold
    }
}

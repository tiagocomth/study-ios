//
//  ExploreGroupsViewModel.swift
//  Study
//

import Foundation
import Combine

final class ExploreGroupsViewModel: ObservableObject {
    /// Filtro de privacidade do segmented control.
    enum PrivacyScope: CaseIterable, Identifiable {
        case all, `public`, `private`

        var id: Self { self }

        var title: String {
            switch self {
            case .all: "Todos"
            case .public: "Público"
            case .private: "Privado"
            }
        }

        /// Valor enviado à API (`nil` = sem filtro).
        var isPrivate: Bool? {
            switch self {
            case .all: nil
            case .public: false
            case .private: true
            }
        }
    }

    weak var coordinator: GroupCoordinator?
    private let worker: ExploreGroupsWorkerProtocol

    @Published private(set) var groups: [StudyGroup] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var privacyScope: PrivacyScope = .all

    private var cancellables = Set<AnyCancellable>()
    private var hasLoaded = false
    private var loadTask: Task<Void, Never>?
    private var pageTask: Task<Void, Never>?

    /// Total de itens disponíveis no backend para o filtro atual.
    private var totalCount = 0
    /// Última página já carregada.
    private var currentPage = 1
    /// Quantas linhas antes do fim disparam o carregamento da próxima página.
    private let prefetchThreshold = 3

    /// Ainda há páginas para carregar?
    var canLoadMore: Bool { groups.count < totalCount }

    init(worker: ExploreGroupsWorkerProtocol) {
        self.worker = worker
        bindFilters()
    }

    /// Primeira carga da tela. Idempotente — só dispara a busca inicial uma vez.
    func onAppear() {
        guard !hasLoaded else { return }
        hasLoaded = true
        loadGroups()
    }

    /// Recarrega a lista a partir do backend (ex.: após criar um grupo).
    func reload() {
        loadGroups()
    }

    func createGroupTapped() {
        coordinator?.presentCreateGroup()
    }

    /// Recarrega quando o texto (com debounce) ou o segmento de privacidade muda.
    private func bindFilters() {
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.loadGroups()
            }
            .store(in: &cancellables)

        // Troca de segmento recarrega na hora (sem debounce).
        $privacyScope
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.loadGroups()
            }
            .store(in: &cancellables)
    }

    /// Primeira página: substitui a lista. Usado na carga inicial, na troca de
    /// filtro e no reload (ex.: após criar um grupo).
    private func loadGroups() {
        let query = currentQuery

        isLoading = true
        errorMessage = nil

        // Cancela cargas em voo (primeira página ou paginação) para não aplicar
        // resultado obsoleto.
        pageTask?.cancel()
        loadTask?.cancel()
        loadTask = Task {
            do {
                let page = try await worker.exploreGroups(filter: query.term, isPrivate: query.isPrivate, page: 1)
                await MainActor.run {
                    // Só aplica se o filtro (texto + privacidade) ainda é o atual.
                    guard !Task.isCancelled, query == currentQuery else { return }
                    groups = page.groups
                    totalCount = page.total
                    currentPage = 1
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    guard !Task.isCancelled, query == currentQuery else { return }
                    // Em erro, limpa a lista para não exibir itens de um filtro anterior.
                    groups = []
                    totalCount = 0
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    /// Chamado quando uma linha aparece: dispara a próxima página ao se aproximar
    /// do fim da lista.
    func loadMoreIfNeeded(currentItem: StudyGroup) {
        guard let index = groups.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let triggerIndex = groups.count - prefetchThreshold
        guard index >= triggerIndex else { return }
        loadNextPage()
    }

    /// Próxima página: acumula na lista existente.
    private func loadNextPage() {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }

        let query = currentQuery
        let nextPage = currentPage + 1

        isLoadingMore = true
        pageTask?.cancel()
        pageTask = Task {
            do {
                let page = try await worker.exploreGroups(filter: query.term, isPrivate: query.isPrivate, page: nextPage)
                await MainActor.run {
                    // Descarta se o filtro mudou no meio do caminho.
                    guard !Task.isCancelled, query == currentQuery else {
                        isLoadingMore = false
                        return
                    }
                    // Evita duplicar itens caso a página chegue mais de uma vez.
                    let existingIds = Set(groups.map(\.id))
                    groups.append(contentsOf: page.groups.filter { !existingIds.contains($0.id) })
                    totalCount = page.total
                    currentPage = nextPage
                    isLoadingMore = false
                }
            } catch {
                await MainActor.run {
                    // Falha de paginação não derruba a lista já carregada.
                    isLoadingMore = false
                }
            }
        }
    }

    /// Identidade do filtro atual (termo + privacidade), usada para descartar
    /// respostas obsoletas.
    private struct Query: Equatable {
        let term: String?
        let isPrivate: Bool?
    }

    private var currentQuery: Query {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return Query(term: trimmed.isEmpty ? nil : trimmed, isPrivate: privacyScope.isPrivate)
    }
}

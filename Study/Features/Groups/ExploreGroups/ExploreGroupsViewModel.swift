//
//  ExploreGroupsViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class ExploreGroupsViewModel: ObservableObject {
    weak var coordinator: GroupCoordinator?
    private let worker: ExploreGroupsWorkerProtocol

    @Published private(set) var groups: [StudyGroup] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var privacyScope: GroupPrivacyFilter = .all

    private var cancellables = Set<AnyCancellable>()
    private var hasLoaded = false
    private var loadTask: Task<Void, Never>?
    private var pageTask: Task<Void, Never>?

    /// Identidade da carga atual. Toda nova busca (filtro, texto ou reload)
    /// incrementa o token; só a resposta do token mais recente é aplicada,
    /// descartando respostas obsoletas ou fora de ordem.
    private var loadToken = 0

    /// Total de itens disponíveis no backend para o filtro atual.
    private var totalCount = 0
    /// Última página já carregada.
    private var currentPage = 1

    /// Ainda há páginas para carregar? (regra no Worker)
    var canLoadMore: Bool { worker.canLoadMore(loaded: groups.count, total: totalCount) }

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
        // Texto: aplica debounce para não disparar a cada tecla.
        let search = $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { _ in () }

        // Segmento: recarrega na troca (sem debounce).
        let privacy = $privacyScope
            .dropFirst()
            .removeDuplicates()
            .map { _ in () }

        // `receive(on:)` garante que o `loadGroups()` rode no próximo ciclo do
        // main actor, e não de forma síncrona durante a atualização da view
        // (origem do warning "Publishing changes from within view updates").
        Publishers.Merge(search, privacy)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadGroups()
            }
            .store(in: &cancellables)
    }

    /// Primeira página: substitui a lista. Usado na carga inicial, na troca de
    /// filtro e no reload (ex.: após criar um grupo).
    private func loadGroups() {
        // Cancela cargas em voo (primeira página ou paginação) para não aplicar
        // resultado obsoleto.
        pageTask?.cancel()
        loadTask?.cancel()
        loadToken += 1
        let token = loadToken
        let searchText = searchText
        let privacy = privacyScope

        // As mutações de `@Published` ficam dentro da `Task` (próximo turno do main
        // actor) para não publicar durante a atualização da view (warning roxo).
        loadTask = Task {
            isLoading = true
            errorMessage = nil
            do {
                let page = try await worker.exploreGroups(searchText: searchText, privacy: privacy, page: 1)
                // Só aplica a resposta se esta ainda for a carga mais recente.
                guard token == loadToken else { return }
                groups = page.groups
                totalCount = page.total
                currentPage = 1
                isLoading = false
            } catch is CancellationError {
                // Cancelamento (troca de filtro) é silencioso — outra carga assume.
            } catch {
                guard token == loadToken else { return }
                // Em erro, limpa a lista para não exibir itens de um filtro anterior.
                groups = []
                totalCount = 0
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    /// Chamado quando uma linha aparece: dispara a próxima página ao se aproximar
    /// do fim da lista (decisão no Worker).
    func loadMoreIfNeeded(currentItem: StudyGroup) {
        guard let index = groups.firstIndex(where: { $0.id == currentItem.id }) else { return }
        guard worker.shouldLoadMore(at: index, loaded: groups.count, total: totalCount) else { return }
        loadNextPage()
    }

    /// Próxima página: acumula na lista existente.
    private func loadNextPage() {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }

        let nextPage = currentPage + 1
        let token = loadToken
        let searchText = searchText
        let privacy = privacyScope

        pageTask?.cancel()
        pageTask = Task {
            isLoadingMore = true
            do {
                let page = try await worker.exploreGroups(searchText: searchText, privacy: privacy, page: nextPage)
                // Descarta se o filtro mudou (token avançou) no meio do caminho.
                guard token == loadToken else {
                    isLoadingMore = false
                    return
                }
                // Evita duplicar itens caso a página chegue mais de uma vez.
                let existingIds = Set(groups.map(\.id))
                groups.append(contentsOf: page.groups.filter { !existingIds.contains($0.id) })
                totalCount = page.total
                currentPage = nextPage
                isLoadingMore = false
            } catch {
                // Falha/cancelamento de paginação não derruba a lista já carregada.
                isLoadingMore = false
            }
        }
    }
}

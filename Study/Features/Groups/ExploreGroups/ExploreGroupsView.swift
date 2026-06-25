//
//  ExploreGroupsView.swift
//  Study
//

import SwiftUI

struct ExploreGroupsView: View {
    @StateObject var viewModel: ExploreGroupsViewModel

    var body: some View {
        VStack(spacing: 0) {
            Picker("Privacidade", selection: $viewModel.privacyScope) {
                ForEach(ExploreGroupsViewModel.PrivacyScope.allCases) { scope in
                    Text(scope.title).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal)
            .padding(.vertical, 8)

            content
        }
            .navigationTitle("Explorar grupos")
            .searchable(text: $viewModel.searchText, prompt: "Buscar grupos")
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.createGroupTapped()
                    } label: {
                        Label("Criar grupo", systemImage: "plus")
                    }
                }
            }
            .task { viewModel.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.groups.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.groups.isEmpty {
            ContentUnavailableView {
                Label("Não foi possível carregar", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Tentar novamente") { viewModel.reload() }
            }
        } else if viewModel.groups.isEmpty {
            ContentUnavailableView(
                "Nenhum grupo encontrado",
                systemImage: "person.3",
                description: Text("Crie um grupo para começar a estudar em conjunto.")
            )
        } else {
            List {
                ForEach(viewModel.groups) { group in
                    GroupRow(group: group)
                        .onAppear { viewModel.loadMoreIfNeeded(currentItem: group) }
                }

                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
    }
}

private struct GroupRow: View {
    let group: StudyGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(group.name)
                .font(.headline)

            if let description = group.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                if group.isPrivate {
                    Label("Privado", systemImage: "lock.fill")
                } else {
                    Label("Público", systemImage: "globe")
                }
                Label("até \(group.maxMembers)", systemImage: "person.2")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

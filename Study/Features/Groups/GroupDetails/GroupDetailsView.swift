//
//  GroupDetailsView.swift
//  Study
//

import SwiftUI

struct GroupDetailsView: View {
    @StateObject var viewModel: GroupDetailsViewModel

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 20)]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            Text("Status: ")
                .font(.subheadline.weight(.bold))
            + Text(viewModel.statusText)
                .font(.subheadline)

            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationBarBackButtonHidden(true)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Button {
                viewModel.back()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Label(viewModel.groupName, systemImage: "info.circle")
                .font(.headline)

            Spacer()

            // Espaço-fantasma para centralizar o título.
            Image(systemName: "chevron.left")
                .font(.title3.weight(.semibold))
                .opacity(0)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && !viewModel.hasAnyMember {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, !viewModel.hasAnyMember {
            ContentUnavailableView {
                Label("Não foi possível carregar", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Tentar novamente") { viewModel.reload() }
            }
        } else {
            membersBoard
        }
    }

    private var membersBoard: some View {
        ScrollView {
            if viewModel.hasAnyMember {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                    ForEach(viewModel.activeMembers) { member in
                        MemberCard(
                            name: member.name,
                            highlight: viewModel.elapsedText(for: member),
                            caption: viewModel.categoryText(for: member),
                            isActive: true
                        )
                    }
                    ForEach(viewModel.inactiveMembers) { member in
                        MemberCard(
                            name: member.name,
                            highlight: "Offline",
                            caption: String(format: "%.1fh totais", member.totalHours),
                            isActive: false
                        )
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            } else {
                Text("Ninguém estudando por aqui ainda.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct MemberCard: View {
    let name: String
    let highlight: String
    let caption: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)

            // Placeholder do avatar (backend ainda não fornece imagem).
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .frame(width: 84, height: 84)
                .overlay {
                    if !isActive {
                        Image(systemName: "moon.zzz.fill")
                            .foregroundStyle(.secondary)
                    }
                }

            Text(highlight)
                .font(.footnote.weight(.bold))
                .monospacedDigit()

            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .opacity(isActive ? 1 : 0.7)
    }
}

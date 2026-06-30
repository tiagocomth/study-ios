//
//  JoinGroupView.swift
//  Study
//

import SwiftUI

struct JoinGroupView: View {
    @StateObject var viewModel: JoinGroupViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            field(title: "Número de Integrantes:") {
                Text("\(viewModel.currentMembersCount)/\(viewModel.maxMembers)  Pessoas")
            }

            field(title: "Administrador") {
                Text(viewModel.administratorName)
            }

            field(title: "Descrição do Grupo:") {
                Text(viewModel.groupDescription ?? "Sem descrição.")
                    .fixedSize(horizontal: false, vertical: true)
            }

            if viewModel.requiresPassword {
                field(title: "Senha da Sala") {
                    SecureField("", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            Spacer(minLength: 0)

            joinButton
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 460)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(alignment: .top) {
            Button {
                viewModel.cancel()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(viewModel.groupName)
                .font(.headline)

            Spacer()

            // Placeholder da imagem do grupo (backend ainda não fornece).
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.secondary.opacity(0.4))
                .frame(width: 64, height: 64)
        }
    }

    private var joinButton: some View {
        Button {
            viewModel.join()
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Entrar no Grupo")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.canJoin)
        .frame(maxWidth: .infinity)
    }

    /// Bloco "título em negrito + conteúdo", repetido no layout.
    private func field<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.bold))
            content()
                .font(.subheadline)
        }
    }
}

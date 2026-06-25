//
//  CreateGroupView.swift
//  Study
//

import SwiftUI

struct CreateGroupView: View {
    @StateObject var viewModel: CreateGroupViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Grupo") {
                    TextField("Nome", text: $viewModel.name)
                    TextField("Descrição", text: $viewModel.groupDescription)
                    Stepper(
                        "Máx. de membros: \(viewModel.maxMembers)",
                        value: $viewModel.maxMembers,
                        in: viewModel.maxMembersRange
                    )
                }

                Section {
                    Toggle("Grupo privado", isOn: $viewModel.isPrivate)
                    if viewModel.isPrivate {
                        SecureField("Senha", text: $viewModel.password)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.callout)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Criar grupo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { viewModel.cancel() }
                        .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Criar") { viewModel.create() }
                            .disabled(!viewModel.canCreate)
                    }
                }
            }
        }
        .frame(minWidth: 380, minHeight: 360)
    }
}

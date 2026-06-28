//
//  StudySessionCategoryFormView.swift
//  Study
//

import SwiftUI

struct StudySessionCategoryFormView: View {
    @StateObject var viewModel: StudySessionCategoryFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: GlobalConfiguration.largeSpacing) {
            header

            AuthTextField(
                title: "Nome da categoria",
                placeholder: "Digite o nome da categoria",
                text: $viewModel.categoryName
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(AppColors.secondaryPure)
            }

            footer
        }
        .padding(GlobalConfiguration.largePadding)
        .frame(minWidth: 420, maxWidth: 460)
        .background(AppColors.neutralWhite)
    }
}

private extension StudySessionCategoryFormView {
    var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: GlobalConfiguration.normalSpacing) {
                Text("Criar categoria")
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.neutralBlack)

                Text("Adicione uma nova matéria para começar seus estudos.")
                    .font(.body)
                    .foregroundStyle(AppColors.neutralGray)
            }

            Spacer()

            Button(action: viewModel.dismiss) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(AppColors.neutralBlack)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
    }

    var footer: some View {
        HStack(spacing: GlobalConfiguration.normalSpacing) {
            Button("Cancelar", action: viewModel.dismiss)
                .buttonStyle(SecondaryButtonStyle())

            Button(action: viewModel.saveCategory) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Criar categoria")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }
}

#Preview {
    StudySessionCategoryFormView(
        viewModel: StudySessionCategoryFormViewModel(worker: StudySessionCategoryFormPreviewWorker())
    )
}

private struct StudySessionCategoryFormPreviewWorker: StudySessionWorkerProtocol {
    func categoryChanges() -> AsyncStream<[StudyCategory]> { AsyncStream { _ in } }
    func activeStudySessionChanges() async -> AsyncStream<LocalStudySession?> { AsyncStream { _ in } }
    func configureTimer(_ mode: StudySessionTimerMode) async throws {}
    func timerChanges() async throws -> AsyncStream<StudySessionTimerState> { AsyncStream { _ in } }
    func validateCategoryName(_ name: String) throws -> String { name }
    func createCategory(_ dto: CreateCategoryDTO) throws -> StudyCategory {
        StudyCategory(categoryId: UUID(), userId: UUID(), name: dto.name, createdAt: "")
    }
    func updateCategory(id: UUID, dto: UpdateCategoryDTO) throws -> StudyCategory {
        StudyCategory(categoryId: id, userId: UUID(), name: dto.name, createdAt: "")
    }
    func deleteCategory(id: UUID) throws {}
    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory] { [] }
    func getActiveStudySession() async -> LocalStudySession? { nil }
    func startStudySession(categoryId: UUID) async throws {}
    func pauseStudySession() async throws {}
    func resumeStudySession() async throws {}
    func finishStudySession() async throws {}
}

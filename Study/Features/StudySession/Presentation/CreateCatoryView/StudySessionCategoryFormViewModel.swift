//
//  StudySessionCategoryFormViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class StudySessionCategoryFormViewModel: ObservableObject {
    weak var coordinator: StudySessionCategoryFormCoordinatorProtocol?
    private let worker: StudySessionWorkerProtocol

    @Published var categoryName: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    init(worker: StudySessionWorkerProtocol) {
        self.worker = worker
    }

    var isFormValid: Bool {
        !trimmedCategoryName.isEmpty
    }

    func saveCategory() {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        do {
            _ = try worker.createCategory(CreateCategoryDTO(name: trimmedCategoryName))
            coordinator?.dismissCreateCategory()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func dismiss() {
        coordinator?.dismissCreateCategory()
    }
}

private extension StudySessionCategoryFormViewModel {
    var trimmedCategoryName: String {
        categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

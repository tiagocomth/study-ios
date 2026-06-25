//
//  StudySessionWorker.swift
//  Study
//

import Foundation

final class StudySessionWorker: StudySessionWorkerProtocol {
    private let categoryOrchestration: CategoryOrchestrationProtocol
    private let studySessionTrackerOrchestration: StudySessionTrackerOrchestrationProtocol
    
    init(
        categoryOrchestration: CategoryOrchestrationProtocol,
        studySessionTrackerOrchestration: StudySessionTrackerOrchestrationProtocol
    ) {
        self.categoryOrchestration = categoryOrchestration
        self.studySessionTrackerOrchestration = studySessionTrackerOrchestration
    }

    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory] {
        try categoryOrchestration.loadCategories(onBackendRefresh: onBackendRefresh)
    }

    func createCategory(
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        try categoryOrchestration.create(dto, onShouldRollback: onShouldRollback)
    }

    func updateCategory(
        id: UUID,
        dto: UpdateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        try categoryOrchestration.update(id: id, dto: dto, onShouldRollback: onShouldRollback)
    }

    func deleteCategory(
        id: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) throws {
        try categoryOrchestration.delete(id: id, onShouldRollback: onShouldRollback)
    }

    func getActiveStudySession() async -> LocalStudySession? {
        await studySessionTrackerOrchestration.getActiveSession()
    }

    func startStudySession(categoryId: UUID) async throws { // TODO: Como vai funcionar para a tela saber se tem q aumentar ou diminuir o tempo
        try await studySessionTrackerOrchestration.start(categoryId: categoryId)
    }

    func pauseStudySession() async throws {
        try await studySessionTrackerOrchestration.pause()
    }

    func resumeStudySession() async throws {
        try await studySessionTrackerOrchestration.resume()
    }

    func finishStudySession() async throws {
        try await studySessionTrackerOrchestration.finish()
    }
}

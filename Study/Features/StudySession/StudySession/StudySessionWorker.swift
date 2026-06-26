//
//  StudySessionWorker.swift
//  Study
//

import Foundation

final class StudySessionWorker: StudySessionWorkerProtocol {
    private let categoryOrchestration: CategoryOrchestrationProtocol
    private let studySessionTrackerOrchestration: StudySessionTrackerOrchestrationProtocol
    private let timerModeStore: StudySessionTimerModeStoreLocalProtocol
    private let timerService: StudySessionTimerServiceProtocol
    private let currentUserId: () -> UUID?
    
    init(
        categoryOrchestration: CategoryOrchestrationProtocol,
        studySessionTrackerOrchestration: StudySessionTrackerOrchestrationProtocol,
        timerModeStore: StudySessionTimerModeStoreLocalProtocol,
        timerService: StudySessionTimerServiceProtocol,
        currentUserId: @escaping () -> UUID?
    ) {
        self.categoryOrchestration = categoryOrchestration
        self.studySessionTrackerOrchestration = studySessionTrackerOrchestration
        self.timerModeStore = timerModeStore
        self.timerService = timerService
        self.currentUserId = currentUserId
    }

    func categoryChanges() -> AsyncStream<[StudyCategory]> {
        categoryOrchestration.categoryChanges()
    }

    func activeStudySessionChanges() async -> AsyncStream<LocalStudySession?> {
        await studySessionTrackerOrchestration.activeSessionChanges()
    }

    func configureTimer(_ mode: StudySessionTimerMode) async throws {
        guard let userId = currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        await timerModeStore.saveMode(mode, userId: userId)
    }

    func timerChanges() async throws -> AsyncStream<StudySessionTimerState> {
        guard let userId = currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        guard let mode = await timerModeStore.getMode(userId: userId) else {
            throw StudySessionWorkerError.studySessionTimerNotConfigured
        }

        let sessionChanges = await studySessionTrackerOrchestration.activeSessionChanges()
        return timerService.timerStates(mode: mode, sessionChanges: sessionChanges)
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

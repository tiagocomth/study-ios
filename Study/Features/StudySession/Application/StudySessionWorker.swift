//
//  StudySessionWorker.swift
//  Study
//

import Foundation

final class StudySessionWorker: StudySessionWorkerProtocol {
    private let categoryManager: CategoryManagerProtocol
    private let studySessionManager: StudySessionManagerProtocol
    private let timerModeStore: StudySessionTimerModeStoreLocalProtocol
    private let timerService: StudySessionTimerServiceProtocol
    private let currentUserId: () -> UUID?
    
    init(
        categoryManager: CategoryManagerProtocol,
        studySessionManager: StudySessionManagerProtocol,
        timerModeStore: StudySessionTimerModeStoreLocalProtocol,
        timerService: StudySessionTimerServiceProtocol,
        currentUserId: @escaping () -> UUID?
    ) {
        self.categoryManager = categoryManager
        self.studySessionManager = studySessionManager
        self.timerModeStore = timerModeStore
        self.timerService = timerService
        self.currentUserId = currentUserId
    }

    func categoryChanges() -> AsyncStream<[StudyCategory]> {
        categoryManager.categoryChanges()
    }

    func activeStudySessionChanges() async -> AsyncStream<LocalStudySession?> {
        await studySessionManager.activeSessionChanges()
    }

    func configureTimer(_ mode: StudySessionTimerMode) async throws {
        guard let userId = currentUserId() else {
            throw StudySessionError.missingCurrentUser
        }

        await timerModeStore.saveMode(mode, userId: userId)
    }

    func timerChanges() async throws -> AsyncStream<StudySessionTimerState> {
        guard let userId = currentUserId() else {
            throw StudySessionError.missingCurrentUser
        }

        guard let mode = await timerModeStore.getMode(userId: userId) else {
            throw StudySessionError.studySessionTimerNotConfigured
        }

        let sessionChanges = await studySessionManager.activeSessionChanges()
        return timerService.timerStates(mode: mode, sessionChanges: sessionChanges)
    }

    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory] {
        try categoryManager.loadCategories(onBackendRefresh: onBackendRefresh)
    }

    func createCategory(
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        try categoryManager.create(dto, onShouldRollback: onShouldRollback)
    }

    func updateCategory(
        id: UUID,
        dto: UpdateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory {
        try categoryManager.update(id: id, dto: dto, onShouldRollback: onShouldRollback)
    }

    func deleteCategory(
        id: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) throws {
        try categoryManager.delete(id: id, onShouldRollback: onShouldRollback)
    }

    func getActiveStudySession() async -> LocalStudySession? {
        await studySessionManager.getActiveSession()
    }

    func startStudySession(categoryId: UUID) async throws { // TODO: Como vai funcionar para a tela saber se tem q aumentar ou diminuir o tempo
        try await studySessionManager.start(categoryId: categoryId)
    }

    func pauseStudySession() async throws {
        try await studySessionManager.pause()
    }

    func resumeStudySession() async throws {
        try await studySessionManager.resume()
    }

    func finishStudySession() async throws {
        try await studySessionManager.finish()
    }
}

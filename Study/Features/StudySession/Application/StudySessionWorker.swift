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

    func validateCategoryName(_ name: String) throws -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw StudySessionError.invalidCategoryName
        }

        return trimmedName
    }

    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory] {
        try categoryManager.loadCategories(onBackendRefresh: onBackendRefresh)
    }

    func createCategory(_ dto: CreateCategoryDTO) throws -> StudyCategory {
        try categoryManager.create(dto)
    }

    func updateCategory(id: UUID, dto: UpdateCategoryDTO) throws -> StudyCategory {
        try categoryManager.update(id: id, dto: dto)
    }

    func deleteCategory(id: UUID) throws {
        try categoryManager.delete(id: id)
    }

    func getActiveStudySession() async -> LocalStudySession? {
        await studySessionManager.getActiveSession()
    }

    func startStudySession(categoryId: UUID, mode: StudySessionTimerMode) async throws {
        try await studySessionManager.start(categoryId: categoryId, mode: mode)
        try await configureTimer(mode)
    }

    func pauseStudySession() async throws {
        try await studySessionManager.pause()
    }

    func resumeStudySession() async throws {
        try await studySessionManager.resume()
    }

    func finishStudySession() async throws {
        guard let id = currentUserId() else { throw StudySessionError.missingCurrentUser }
        try await studySessionManager.finish(endDate: nil)
        await timerModeStore.clear(userId: id)
    }
    
    private func configureTimer(_ mode: StudySessionTimerMode) async throws {
        guard let userId = currentUserId() else {
            throw StudySessionError.missingCurrentUser
        }

        await timerModeStore.saveMode(mode, userId: userId)
    }
}

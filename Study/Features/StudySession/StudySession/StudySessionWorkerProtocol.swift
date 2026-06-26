//
//  StudySessionWorkerProtocol.swift
//  Study
//

import Foundation

typealias CategoriesRefreshCallback = @MainActor @Sendable ([StudyCategory]) -> Void
typealias ShouldRollback = @MainActor @Sendable (Error) -> Void

@MainActor
protocol StudySessionWorkerProtocol {
    func categoryChanges() -> AsyncStream<[StudyCategory]>
    func activeStudySessionChanges() async -> AsyncStream<LocalStudySession?>
    func configureTimer(_ mode: StudySessionTimerMode) async throws
    func timerChanges() async throws -> AsyncStream<StudySessionTimerState>
    
    func createCategory(
        _ dto: CreateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory
    
    func updateCategory(
        id: UUID,
        dto: UpdateCategoryDTO,
        onShouldRollback: @escaping ShouldRollback
    ) throws -> StudyCategory
    
    func deleteCategory(
        id: UUID,
        onShouldRollback: @escaping ShouldRollback
    ) throws
    
    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory]
    func getActiveStudySession() async -> LocalStudySession?
    func startStudySession(categoryId: UUID) async throws
    func pauseStudySession() async throws
    func resumeStudySession() async throws
    func finishStudySession() async throws
}

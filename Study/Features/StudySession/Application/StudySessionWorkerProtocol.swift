//
//  StudySessionWorkerProtocol.swift
//  Study
//

import Foundation

typealias CategoriesRefreshCallback = @MainActor @Sendable ([StudyCategory]) -> Void

@MainActor
protocol StudySessionWorkerProtocol {
    func categoryChanges() -> AsyncStream<[StudyCategory]>
    func activeStudySessionChanges() async -> AsyncStream<LocalStudySession?>
    func timerChanges() async throws -> AsyncStream<StudySessionTimerState>
    
    func validateCategoryName(_ name: String) throws -> String
    
    func createCategory(_ dto: CreateCategoryDTO) throws -> StudyCategory
    func updateCategory(id: UUID, dto: UpdateCategoryDTO) throws -> StudyCategory
    func deleteCategory(id: UUID) throws
    func loadCategories(onBackendRefresh: @escaping CategoriesRefreshCallback) throws -> [StudyCategory]
    
    func getActiveStudySession() async -> LocalStudySession?
    func startStudySession(categoryId: UUID, mode: StudySessionTimerMode) async throws
    func pauseStudySession() async throws
    func resumeStudySession() async throws
    func finishStudySession() async throws
}

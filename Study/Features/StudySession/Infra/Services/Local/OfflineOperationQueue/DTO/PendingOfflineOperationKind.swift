//
//  PendingOfflineOperationKind.swift
//  Study
//

import Foundation

nonisolated enum PendingOfflineOperationKind: Codable, Equatable, Sendable {
    case startStudySession(StartStudySessionDTO)
    case pauseStudySession(id: UUID, dto: PauseStudySessionDTO)
    case resumeStudySession(id: UUID, dto: ResumeStudySessionDTO)
    case endStudySession(id: UUID, dto: EndStudySessionDTO)

    case createCategory(CreateCategoryDTO)
    case updateCategory(id: UUID, dto: UpdateCategoryDTO)
    case deleteCategory(UUID)
}

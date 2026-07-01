//
//  StudySessionAPIProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionAPIProtocol {
    func last() async throws(NetworkError) -> StudySessionDTO?
    func start(_ dto: StartStudySessionDTO) async throws(NetworkError)
    func pause(id: UUID, dto: PauseStudySessionDTO) async throws(NetworkError)
    func resume(id: UUID, dto: ResumeStudySessionDTO) async throws(NetworkError)
    func finish(id: UUID, dto: EndStudySessionDTO) async throws(NetworkError)
    func delete(id: UUID) async throws(NetworkError)
}

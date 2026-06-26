//
//  StudySessionRemote.swift
//  Study
//

import Foundation

final class StudySessionRemote: StudySessionRemoteProtocol {
    private let apiClient: APIClientProtocol
    private let logger: DomainLogging

    init(
        apiClient: APIClientProtocol,
        logger: DomainLogging = StudySessionTrackerLogger()
    ) {
        self.apiClient = apiClient
        self.logger = logger
    }

    func start(_ dto: StartStudySessionDTO) async throws(NetworkError) {
        logger.info("Sending study session start \(dto.sessionId.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.startStudySession(dto))
    }

    func pause(id: UUID, dto: PauseStudySessionDTO) async throws(NetworkError) {
        logger.info("Sending study session pause \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.pauseStudySession(id: id, dto: dto))
    }

    func resume(id: UUID, dto: ResumeStudySessionDTO) async throws(NetworkError) {
        logger.info("Sending study session resume \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.resumeStudySession(id: id, dto: dto))
    }

    func finish(id: UUID, dto: EndStudySessionDTO) async throws(NetworkError) {
        logger.info("Sending study session finish \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.endStudySession(id: id, dto: dto))
    }

    func delete(id: UUID) async throws(NetworkError) {
        logger.info("Sending study session delete \(id.uuidString)")
        let _: EmptyResponse = try await apiClient.request(StudySessionEndpoint.deleteStudySession(id))
    }
}

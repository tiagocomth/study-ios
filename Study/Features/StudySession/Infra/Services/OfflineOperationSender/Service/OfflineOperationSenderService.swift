//
//  OfflineOperationSenderService.swift
//  Study
//

import Foundation

final class OfflineOperationSenderService: OfflineOperationSenderServiceProtocol {
    private let apiClient: APIClientProtocol
    private let logger: DomainLogging

    init(
        apiClient: APIClientProtocol,
        logger: DomainLogging = OfflineOperationQueueLogger()
    ) {
        self.apiClient = apiClient
        self.logger = logger
    }

    func send(_ operation: PendingOfflineOperation) async throws(NetworkError) {
        logger.info("Sending offline operation \(operation.id.uuidString)")

        switch operation.kind {
        case .startStudySession(let dto):
            let _: EmptyResponse = try await apiClient.request(
                StudySessionEndpoint.startStudySession(dto)
            )

        case .pauseStudySession(let id, let dto):
            let _: EmptyResponse = try await apiClient.request(
                StudySessionEndpoint.pauseStudySession(id: id, dto: dto)
            )

        case .resumeStudySession(let id, let dto):
            let _: EmptyResponse = try await apiClient.request(
                StudySessionEndpoint.resumeStudySession(id: id, dto: dto)
            )

        case .endStudySession(let id, let dto):
            let _: EmptyResponse = try await apiClient.request(
                StudySessionEndpoint.endStudySession(id: id, dto: dto)
            )

        case .createCategory(let dto):
            let _: StudyCategory = try await apiClient.request(
                StudySessionEndpoint.createCategory(dto)
            )

        case .updateCategory(let id, let dto):
            let _: StudyCategory = try await apiClient.request(
                StudySessionEndpoint.updateCategory(id: id, dto: dto)
            )

        case .deleteCategory(let id):
            let _: EmptyResponse = try await apiClient.request(
                StudySessionEndpoint.deleteCategory(id)
            )
        }

        logger.info("Sent offline operation \(operation.id.uuidString)")
    }
}

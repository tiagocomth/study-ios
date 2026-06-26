//
//  OfflineOperationSender.swift
//  Study
//

import Foundation

final class OfflineOperationSender: OfflineOperationSenderProtocol {
    private let studySessionAPI: StudySessionAPIProtocol
    private let categoryAPI: CategoryAPIProtocol
    private let logger: DomainLogging

    init(
        studySessionAPI: StudySessionAPIProtocol,
        categoryAPI: CategoryAPIProtocol,
        logger: DomainLogging = OfflineOperationQueueLogger()
    ) {
        self.studySessionAPI = studySessionAPI
        self.categoryAPI = categoryAPI
        self.logger = logger
    }

    func send(_ operation: PendingOfflineOperation) async throws(NetworkError) {
        logger.info("Sending offline operation \(operation.id.uuidString)")

        switch operation.kind {
        case .startStudySession(let dto):
            try await studySessionAPI.start(dto)

        case .pauseStudySession(let id, let dto):
            try await studySessionAPI.pause(id: id, dto: dto)

        case .resumeStudySession(let id, let dto):
            try await studySessionAPI.resume(id: id, dto: dto)

        case .endStudySession(let id, let dto):
            try await studySessionAPI.finish(id: id, dto: dto)

        case .deleteStudySession(let id):
            try await studySessionAPI.delete(id: id)

        case .createCategory(let dto):
            try await categoryAPI.create(dto)

        case .updateCategory(let id, let dto):
            try await categoryAPI.update(id: id, dto: dto)

        case .deleteCategory(let id):
            try await categoryAPI.delete(id: id)
        }

        logger.info("Sent offline operation \(operation.id.uuidString)")
    }
}

//
//  OfflineOperationSenderRemote.swift
//  Study
//

import Foundation

final class OfflineOperationSenderRemote: OfflineOperationSenderRemoteProtocol {
    private let studySessionRemoteService: StudySessionRemoteProtocol
    private let categoryService: CategoryRemoteProtocol
    private let logger: DomainLogging

    init(
        studySessionRemoteService: StudySessionRemoteProtocol,
        categoryService: CategoryRemoteProtocol,
        logger: DomainLogging = OfflineOperationQueueLogger()
    ) {
        self.studySessionRemoteService = studySessionRemoteService
        self.categoryService = categoryService
        self.logger = logger
    }

    func send(_ operation: PendingOfflineOperation) async throws(NetworkError) {
        logger.info("Sending offline operation \(operation.id.uuidString)")

        switch operation.kind {
        case .startStudySession(let dto):
            try await studySessionRemoteService.start(dto)

        case .pauseStudySession(let id, let dto):
            try await studySessionRemoteService.pause(id: id, dto: dto)

        case .resumeStudySession(let id, let dto):
            try await studySessionRemoteService.resume(id: id, dto: dto)

        case .endStudySession(let id, let dto):
            try await studySessionRemoteService.finish(id: id, dto: dto)

        case .createCategory(let dto):
            try await categoryService.create(dto)

        case .updateCategory(let id, let dto):
            try await categoryService.update(id: id, dto: dto)

        case .deleteCategory(let id):
            try await categoryService.delete(id: id)
        }

        logger.info("Sent offline operation \(operation.id.uuidString)")
    }
}

//
//  StudySessionManager.swift
//  Study
//

import Foundation

final class StudySessionManager: StudySessionManagerProtocol {
    private let studySessionTracker: StudySessionTrackerLocalProtocol
    private let studySessionAPI: StudySessionAPIProtocol
    private let operationManager: OperationManagerProtocol
    private let currentUserId: () -> UUID?
    
    init(
        studySessionTracker: StudySessionTrackerLocalProtocol,
        studySessionAPI: StudySessionAPIProtocol,
        operationManager: OperationManagerProtocol,
        currentUserId: @escaping () -> UUID?
    ) {
        self.studySessionTracker = studySessionTracker
        self.studySessionAPI = studySessionAPI
        self.operationManager = operationManager
        self.currentUserId = currentUserId
    }

    func activeSessionChanges() async -> AsyncStream<LocalStudySession?> {
        guard let userId = await currentUserId() else {
            return AsyncStream { continuation in
                continuation.yield(nil)
                continuation.finish()
            }
        }

        return await studySessionTracker.sessionChanges(userId: userId)
    }
    
    func getActiveSession() async -> LocalStudySession? {
        guard let userId = await currentUserId() else { return nil }
        await studySessionTracker.ensureRestored(userId: userId)
        return await studySessionTracker.getActiveSession(userId: userId)
    }
    
    func start(categoryId: UUID) async throws {
        guard let userId = await currentUserId() else {
            throw StudySessionError.missingCurrentUser
        }

        let action = try await studySessionTracker.start(categoryId: categoryId, userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
    }
    
    func pause() async throws {
        guard let userId = await currentUserId() else {
            throw StudySessionError.missingCurrentUser
        }

        let action = try await studySessionTracker.pause(userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
    }
    
    func resume() async throws {
        guard let userId = await currentUserId() else {
            throw StudySessionError.missingCurrentUser
        }

        let action = try await studySessionTracker.resume(userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
    }
    
    func finish() async throws {
        guard let userId = await currentUserId() else {
            throw StudySessionError.missingCurrentUser
        }

        let action = try await studySessionTracker.finish(userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
            await studySessionTracker.clear(userId: userId)
        }
    }
}

private extension StudySessionManager {
    func sendRemote(_ action: StudySessionTrackerAction, userId: UUID) async {
        switch action {
        case .resumedAndFinished(let sessionId, let resumeDTO, let endDTO):
            await sendResumeAndFinish(
                sessionId: sessionId,
                resumeDTO: resumeDTO,
                endDTO: endDTO,
                userId: userId
            )

        default:
            _ = await operationManager.dispatch(action.pendingOperationKind, userId: userId) { () async throws(NetworkError) -> Void in
                try await sendRemoteRequest(for: action)
            }
        }
    }

    func sendRemoteRequest(for action: StudySessionTrackerAction) async throws(NetworkError) {
        switch action {
        case .started(let dto):
            try await studySessionAPI.start(dto)

        case .paused(let sessionId, let dto):
            try await studySessionAPI.pause(id: sessionId, dto: dto)

        case .resumed(let sessionId, let dto):
            try await studySessionAPI.resume(id: sessionId, dto: dto)

        case .finished(let sessionId, let dto):
            try await studySessionAPI.finish(id: sessionId, dto: dto)

        case .resumedAndFinished:
            return
        }
    }

    func sendResumeAndFinish(
        sessionId: UUID,
        resumeDTO: ResumeStudySessionDTO,
        endDTO: EndStudySessionDTO,
        userId: UUID
    ) async {
        let resumeKind = PendingOfflineOperationKind.resumeStudySession(id: sessionId, dto: resumeDTO)
        let finishKind = PendingOfflineOperationKind.endStudySession(id: sessionId, dto: endDTO)

        let resumeResult = await operationManager.dispatch(resumeKind, userId: userId) { () async throws(NetworkError) -> Void in
            try await studySessionAPI.resume(id: sessionId, dto: resumeDTO)
        }

        switch resumeResult {
        case .sent:
            _ = await operationManager.dispatch(finishKind, userId: userId) { () async throws(NetworkError) -> Void in
                try await studySessionAPI.finish(id: sessionId, dto: endDTO)
            }
        case .enqueued:
            try? await operationManager.enqueue(finishKind, userId: userId)
        case .rollback:
            return
        case .failed:
            return
        }
    }
}

private extension StudySessionTrackerAction {
    var pendingOperationKind: PendingOfflineOperationKind {
        switch self {
        case .started(let dto):
            .startStudySession(dto)
        case .paused(let sessionId, let dto):
            .pauseStudySession(id: sessionId, dto: dto)
        case .resumed(let sessionId, let dto):
            .resumeStudySession(id: sessionId, dto: dto)
        case .finished(let sessionId, let dto):
            .endStudySession(id: sessionId, dto: dto)
        case .resumedAndFinished(let sessionId, let resumeDTO, _):
            .resumeStudySession(id: sessionId, dto: resumeDTO)
        }
    }
}

//
//  StudySessionTrackerOrchestration.swift
//  Study
//

import Foundation

final class StudySessionTrackerOrchestration: StudySessionTrackerOrchestrationProtocol {
    private let studySessionTracker: StudySessionTrackerLocalProtocol
    private let studySessionRemote: StudySessionRemoteProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let currentUserId: () -> UUID?
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date
    
    init(
        studySessionTracker: StudySessionTrackerLocalProtocol,
        studySessionRemote: StudySessionRemoteProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        currentUserId: @escaping () -> UUID?,
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.studySessionTracker = studySessionTracker
        self.studySessionRemote = studySessionRemote
        self.offlineOperationQueue = offlineOperationQueue
        self.currentUserId = currentUserId
        self.makeId = makeId
        self.now = now
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
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.start(categoryId: categoryId, userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
    }
    
    func pause() async throws {
        guard let userId = await currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.pause(userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
    }
    
    func resume() async throws {
        guard let userId = await currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.resume(userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
    }
    
    func finish() async throws {
        guard let userId = await currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.finish(userId: userId)
        Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
    }
}

private extension StudySessionTrackerOrchestration {
    func hasPendingOperations(userId: UUID) async -> Bool {
        await offlineOperationQueue.ensureRestored(userId: userId)
        return await offlineOperationQueue.peek(userId: userId) != nil
    }
    
    func sendRemote(_ action: StudySessionTrackerAction, userId: UUID) async {
        if await hasPendingOperations(userId: userId) {
            await enqueue(action, userId: userId)
            return
        }

        switch action {
        case .started(let dto):
            await sendOrEnqueue(.startStudySession(dto), userId: userId) { () async throws(NetworkError) in
                try await studySessionRemote.start(dto)
            }
            
        case .paused(let sessionId, let dto):
            await sendOrEnqueue(.pauseStudySession(id: sessionId, dto: dto), userId: userId) { () async throws(NetworkError) in
                try await studySessionRemote.pause(id: sessionId, dto: dto)
            }
            
        case .resumed(let sessionId, let dto):
            await sendOrEnqueue(.resumeStudySession(id: sessionId, dto: dto), userId: userId) { () async throws(NetworkError) in
                try await studySessionRemote.resume(id: sessionId, dto: dto)
            }
            
        case .finished(let sessionId, let dto):
            await sendOrEnqueue(.endStudySession(id: sessionId, dto: dto), userId: userId) { () async throws(NetworkError) in
                try await studySessionRemote.finish(id: sessionId, dto: dto)
            }
            
        case .resumedAndFinished(let sessionId, let resumeDTO, let endDTO):
            await sendResumeAndFinish(sessionId: sessionId, resumeDTO: resumeDTO, endDTO: endDTO, userId: userId)
        }
    }

    private func enqueue(_ action: StudySessionTrackerAction, userId: UUID) async {
        switch action {
        case .started(let dto):
            try? await offlineOperationQueue.enqueue(makeOperation(.startStudySession(dto)), userId: userId)

        case .paused(let sessionId, let dto):
            try? await offlineOperationQueue.enqueue(makeOperation(.pauseStudySession(id: sessionId, dto: dto)), userId: userId)

        case .resumed(let sessionId, let dto):
            try? await offlineOperationQueue.enqueue(makeOperation(.resumeStudySession(id: sessionId, dto: dto)), userId: userId)

        case .finished(let sessionId, let dto):
            try? await offlineOperationQueue.enqueue(makeOperation(.endStudySession(id: sessionId, dto: dto)), userId: userId)

        case .resumedAndFinished(let sessionId, let resumeDTO, let endDTO):
            let operations = [
                makeOperation(.resumeStudySession(id: sessionId, dto: resumeDTO)),
                makeOperation(.endStudySession(id: sessionId, dto: endDTO))
            ]
            try? await offlineOperationQueue.enqueue(operations, userId: userId)
        }
    }
    
    private func sendOrEnqueue(
        _ kind: PendingOfflineOperationKind,
        userId: UUID,
        sendRemote: () async throws(NetworkError) -> Void
    ) async {
        do {
            try await sendRemote()
        } catch {
            try? await enqueue(error, kind, userId: userId)
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
        
        do {
            try await studySessionRemote.resume(id: sessionId, dto: resumeDTO)
        } catch {
            try? await enqueue(error, [resumeKind, finishKind], userId: userId)
            return
        }
        
        await sendOrEnqueue(finishKind, userId: userId) { () async throws(NetworkError) in
            try await studySessionRemote.finish(id: sessionId, dto: endDTO)
        }
    }
    
    func enqueue(
        _ error: NetworkError,
        _ kind: PendingOfflineOperationKind,
        userId: UUID
    ) async throws {
        guard OfflineRetryPolicy.shouldEnqueue(error) else { return }
        await offlineOperationQueue.ensureRestored(userId: userId)
        try await offlineOperationQueue.enqueue(makeOperation(kind), userId: userId)
    }
    
    func enqueue(
        _ error: NetworkError,
        _ kinds: [PendingOfflineOperationKind],
        userId: UUID
    ) async throws {
        guard OfflineRetryPolicy.shouldEnqueue(error) else { return }
        await offlineOperationQueue.ensureRestored(userId: userId)
        try await offlineOperationQueue.enqueue(kinds.map(makeOperation), userId: userId)
    }
    
    func makeOperation(_ kind: PendingOfflineOperationKind) -> PendingOfflineOperation {
        PendingOfflineOperation(
            id: makeId(),
            createdAt: now(),
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: kind
        )
    }
}

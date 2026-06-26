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
    private var tasks: [Task<Void, Never>] = []
    
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
    
    func getActiveSession() async -> LocalStudySession? {
        guard let userId = currentUserId() else { return nil }
        await studySessionTracker.ensureRestored(userId: userId)
        return await studySessionTracker.getActiveSession(userId: userId)
    }
    
    func start(categoryId: UUID) async throws {
        guard let userId = currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.start(categoryId: categoryId, userId: userId)
        await send(action, userId: userId)
    }
    
    func pause() async throws {
        guard let userId = currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.pause(userId: userId)
        await send(action, userId: userId)
    }
    
    func resume() async throws {
        guard let userId = currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.resume(userId: userId)
        await send(action, userId: userId)
    }
    
    func finish() async throws {
        guard let userId = currentUserId() else {
            throw StudySessionWorkerError.missingCurrentUser
        }

        let action = try await studySessionTracker.finish(userId: userId)
        await send(action, userId: userId)
    }
    
    deinit {
        for task in tasks {
            task.cancel()
        }
    }
}

private extension StudySessionTrackerOrchestration {
    func send(_ action: StudySessionTrackerAction, userId: UUID) async {
        let task = Task { [weak self] in
            guard let self else { return }
            await sendRemote(action, userId: userId)
        }
        
        await MainActor.run {
            tasks.append(task)
        }
    }
    
    func sendRemote(_ action: StudySessionTrackerAction, userId: UUID) async {
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
    
    func sendOrEnqueue(
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

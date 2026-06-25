//
//  StudySessionTrackerOrchestration.swift
//  Study
//

import Foundation

final class StudySessionTrackerOrchestration: StudySessionTrackerOrchestrationProtocol {
    private let studySessionTracker: StudySessionTrackerLocalProtocol
    private let studySessionRemote: StudySessionRemoteProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date
    private var tasks: [Task<Void, Never>] = []
    
    init(
        studySessionTracker: StudySessionTrackerLocalProtocol,
        studySessionRemote: StudySessionRemoteProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.studySessionTracker = studySessionTracker
        self.studySessionRemote = studySessionRemote
        self.offlineOperationQueue = offlineOperationQueue
        self.makeId = makeId
        self.now = now
    }
    
    func getActiveSession() async -> LocalStudySession? {
        await studySessionTracker.getActiveSession()
    }
    
    func start(categoryId: UUID) async throws {
        let action = try await studySessionTracker.start(categoryId: categoryId)
        await send(action)
    }
    
    func pause() async throws {
        let action = try await studySessionTracker.pause()
        await send(action)
    }
    
    func resume() async throws {
        let action = try await studySessionTracker.resume()
        await send(action)
    }
    
    func finish() async throws {
        let action = try await studySessionTracker.finish()
        await send(action)
    }
    
    deinit {
        for task in tasks {
            task.cancel()
        }
    }
}

private extension StudySessionTrackerOrchestration {
    func send(_ action: StudySessionTrackerAction) async {
        let task = Task { [weak self] in
            guard let self else { return }
            await sendRemote(action)
        }
        
        await MainActor.run {
            tasks.append(task)
        }
    }
    
    func sendRemote(_ action: StudySessionTrackerAction) async {
        switch action {
        case .started(let dto):
            await sendOrEnqueue(.startStudySession(dto)) { () async throws(NetworkError) in
                try await studySessionRemote.start(dto)
            }
            
        case .paused(let sessionId, let dto):
            await sendOrEnqueue(.pauseStudySession(id: sessionId, dto: dto)) { () async throws(NetworkError) in
                try await studySessionRemote.pause(id: sessionId, dto: dto)
            }
            
        case .resumed(let sessionId, let dto):
            await sendOrEnqueue(.resumeStudySession(id: sessionId, dto: dto)) { () async throws(NetworkError) in
                try await studySessionRemote.resume(id: sessionId, dto: dto)
            }
            
        case .finished(let sessionId, let dto):
            await sendOrEnqueue(.endStudySession(id: sessionId, dto: dto)) { () async throws(NetworkError) in
                try await studySessionRemote.finish(id: sessionId, dto: dto)
            }
            
        case .resumedAndFinished(let sessionId, let resumeDTO, let endDTO):
            await sendResumeAndFinish(sessionId: sessionId, resumeDTO: resumeDTO, endDTO: endDTO)
        }
    }
    
    func sendOrEnqueue(
        _ kind: PendingOfflineOperationKind,
        sendRemote: () async throws(NetworkError) -> Void
    ) async {
        do {
            try await sendRemote()
        } catch {
            try? await enqueue(error, kind)
        }
    }
    
    func sendResumeAndFinish(
        sessionId: UUID,
        resumeDTO: ResumeStudySessionDTO,
        endDTO: EndStudySessionDTO
    ) async {
        let resumeKind = PendingOfflineOperationKind.resumeStudySession(id: sessionId, dto: resumeDTO)
        let finishKind = PendingOfflineOperationKind.endStudySession(id: sessionId, dto: endDTO)
        
        do {
            try await studySessionRemote.resume(id: sessionId, dto: resumeDTO)
        } catch {
            try? await enqueue(error, [resumeKind, finishKind])
            return
        }
        
        await sendOrEnqueue(finishKind) { () async throws(NetworkError) in
            try await studySessionRemote.finish(id: sessionId, dto: endDTO)
        }
    }
    
    func enqueue(
        _ error: NetworkError,
        _ kind: PendingOfflineOperationKind
    ) async throws {
        guard OfflineRetryPolicy.shouldEnqueue(error) else { return }
        try await offlineOperationQueue.enqueue(makeOperation(kind))
    }
    
    func enqueue(
        _ error: NetworkError,
        _ kinds: [PendingOfflineOperationKind]
    ) async throws {
        guard OfflineRetryPolicy.shouldEnqueue(error) else { return }
        try await offlineOperationQueue.enqueue(kinds.map(makeOperation))
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

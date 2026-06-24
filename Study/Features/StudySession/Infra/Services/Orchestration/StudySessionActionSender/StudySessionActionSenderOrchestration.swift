//
//  StudySessionActionSenderOrchestration.swift
//  Study
//

import Foundation

final class StudySessionActionSenderOrchestration: StudySessionActionSenderOrchestrationProtocol {
    private let offlineOperationSender: OfflineOperationSenderRemoteProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let makeId: @Sendable () -> UUID
    private let now: @Sendable () -> Date

    init(
        offlineOperationSender: OfflineOperationSenderRemoteProtocol,
        offlineOperationQueue: OfflineOperationQueueLocalProtocol,
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.offlineOperationSender = offlineOperationSender
        self.offlineOperationQueue = offlineOperationQueue
        self.makeId = makeId
        self.now = now
    }

    func send(_ action: StudySessionTrackerAction) async throws {
        try await send(makeOperations(for: action))
    }
}

private extension StudySessionActionSenderOrchestration {
    func makeOperations(for action: StudySessionTrackerAction) -> [PendingOfflineOperation] {
        switch action {
        case .started(let dto):
            [makeOperation(.startStudySession(dto))]
        case .paused(let sessionId, let dto):
            [makeOperation(.pauseStudySession(id: sessionId, dto: dto))]
        case .resumed(let sessionId, let dto):
            [makeOperation(.resumeStudySession(id: sessionId, dto: dto))]
        case .finished(let sessionId, let dto):
            [makeOperation(.endStudySession(id: sessionId, dto: dto))]
        case .resumedAndFinished(let sessionId, let resumeDTO, let endDTO):
            [
                makeOperation(.resumeStudySession(id: sessionId, dto: resumeDTO)),
                makeOperation(.endStudySession(id: sessionId, dto: endDTO))
            ]
        }
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

    func send(_ operations: [PendingOfflineOperation]) async throws {
        for index in operations.indices {
            do {
                try await offlineOperationSender.send(operations[index])
            } catch {
                guard OfflineRetryPolicy.shouldEnqueue(error) else {
                    throw error
                }

                try await enqueue(Array(operations[index...]))
                return
            }
        }
    }

    func enqueue(_ operations: [PendingOfflineOperation]) async throws {
        try await offlineOperationQueue.enqueue(operations)
    }
}

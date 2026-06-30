//
//  StudySessionTrackerLocal.swift
//  Study
//

import Foundation

actor StudySessionTrackerLocal: StudySessionTrackerLocalProtocol {
    private var activeSessionsByUser: [UUID: LocalStudySession] = [:]
    private var restoreStatesByUser: [UUID: RestoreState] = [:]
    private var sessionChangeContinuationsByUser: [UUID: [UUID: AsyncStream<LocalStudySession?>.Continuation]] = [:]

    private let userDefaults: UserDefaults
    private let key: String
    private let now: @Sendable () -> Date
    private let makeId: @Sendable () -> UUID
    private let logger: DomainLogging

    init(
        userDefaults: UserDefaults = .standard,
        key: String = AppKeys.activeStudySession.rawValue,
        now: @escaping @Sendable () -> Date = { Date() },
        makeId: @escaping @Sendable () -> UUID = { UUID() },
        logger: DomainLogging = StudySessionTrackerLogger()
    ) {
        self.userDefaults = userDefaults
        self.key = key
        self.now = now
        self.makeId = makeId
        self.logger = logger
    }

    func sessionChanges(userId: UUID) -> AsyncStream<LocalStudySession?> {
        let streamId = UUID()

        return AsyncStream { continuation in
            sessionChangeContinuationsByUser[userId, default: [:]][streamId] = continuation

            continuation.onTermination = { @Sendable [weak self] _ in
                Task {
                    await self?.removeSessionContinuation(streamId: streamId, userId: userId)
                }
            }

            Task {
                await self.ensureRestored(userId: userId)
                self.emitSessionChanges(for: userId)
            }
        }
    }

    func getActiveSession(userId: UUID) -> LocalStudySession? {
        activeSessionsByUser[userId]
    }

    func restoreState(for userId: UUID) -> RestoreState {
        restoreStatesByUser[userId] ?? .notStarted
    }

    func ensureRestored(userId: UUID) async {
        guard restoreState(for: userId) != .restored else { return }
        await restore(userId: userId)
    }

    func start(categoryId: UUID, userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction {
        await ensureRestored(userId: userId)

        if let activeSession = activeSessionsByUser[userId], activeSession.state != .finished {
            logger.error("Failed to start study session: active session already exists")
            throw StudySessionTrackerLocalError.activeSessionAlreadyExists
        }

        let session = LocalStudySession(
            sessionId: makeId(),
            categoryId: categoryId,
            startDate: now(),
            endDate: nil,
            state: .running,
            pauses: []
        )

        try await persist(session, userId: userId)
        emitSessionChanges(for: userId)
        logger.info("Started study session \(session.sessionId.uuidString)")

        return .started(
            StartStudySessionDTO(
                sessionId: session.sessionId,
                startDate: session.startDate,
                categoryId: session.categoryId
            )
        )
    }

    func pause(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction {
        await ensureRestored(userId: userId)
        var session = try requireActiveSession(userId: userId)

        switch session.state {
        case .running:
            break
        case .paused:
            logger.error("Failed to pause study session: session is already paused")
            throw StudySessionTrackerLocalError.sessionAlreadyPaused
        case .finished:
            logger.error("Failed to pause study session: session is already finished")
            throw StudySessionTrackerLocalError.sessionAlreadyFinished
        }

        let pause = LocalStudyPause(
            pauseId: makeId(),
            startedAt: now(),
            endedAt: nil
        )

        session.pauses.append(pause)
        session.state = .paused

        try await persist(session, userId: userId)
        emitSessionChanges(for: userId)
        logger.info("Paused study session \(session.sessionId.uuidString) with pause \(pause.pauseId.uuidString)")

        return .paused(
            sessionId: session.sessionId,
            dto: PauseStudySessionDTO(
                pauseId: pause.pauseId,
                startedAt: pause.startedAt
            )
        )
    }

    func resume(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction {
        await ensureRestored(userId: userId)
        var session = try requireActiveSession(userId: userId)

        switch session.state {
        case .running:
            logger.error("Failed to resume study session: session is not paused")
            throw StudySessionTrackerLocalError.sessionIsNotPaused
        case .paused:
            break
        case .finished:
            logger.error("Failed to resume study session: session is already finished")
            throw StudySessionTrackerLocalError.sessionAlreadyFinished
        }

        let pauseIndex = try openPauseIndex(in: session)

        let endedAt = now()
        session.pauses[pauseIndex].endedAt = endedAt
        session.state = .running

        try await persist(session, userId: userId)
        emitSessionChanges(for: userId)
        logger.info("Resumed study session \(session.sessionId.uuidString)")

        return .resumed(
            sessionId: session.sessionId,
            dto: ResumeStudySessionDTO(
                endedAt: endedAt
            )
        )
    }

    func finish(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction {
        await ensureRestored(userId: userId)
        var session = try requireActiveSession(userId: userId)

        guard session.state != .finished else {
            logger.error("Failed to finish study session: session is already finished")
            throw StudySessionTrackerLocalError.sessionAlreadyFinished
        }

        let endDate = now() //TODO: Pensar em como vou fazer isso, porque no couchdowmn

        var closePauseDTO: ResumeStudySessionDTO?

        if session.state == .paused {
            let pauseIndex = try openPauseIndex(in: session)
            
            session.pauses[pauseIndex].endedAt = endDate
            closePauseDTO = ResumeStudySessionDTO(
                endedAt: endDate
            )
        }

        session.endDate = endDate
        session.state = .finished

        try await persist(session, userId: userId)
        emitSessionChanges(for: userId)
        logger.info("Finished study session \(session.sessionId.uuidString)")

        let endDTO = EndStudySessionDTO(
            endDate: endDate
        )

        if let closePauseDTO {
            return .resumedAndFinished(sessionId: session.sessionId, resume: closePauseDTO, end: endDTO)
        }

        return .finished(sessionId: session.sessionId, dto: endDTO)
    }

    func clear(userId: UUID) {
        userDefaults.removeObject(forKey: key(for: userId))
        activeSessionsByUser[userId] = nil
        emitSessionChanges(for: userId)
        logger.info("Cleared active study session")
    }

    private func requireActiveSession(userId: UUID) throws(StudySessionTrackerLocalError) -> LocalStudySession {
        guard let activeSession = activeSessionsByUser[userId] else {
            logger.error("Failed to read active study session: session not found")
            throw StudySessionTrackerLocalError.sessionNotFound
        }

        return activeSession
    }

    private func openPauseIndex(in session: LocalStudySession) throws(StudySessionTrackerLocalError) -> Int {
        let openIndexes = session.pauses.indices.filter { session.pauses[$0].endedAt == nil }

        guard let openIndex = openIndexes.first else {
            logger.error("Failed to find open pause for study session \(session.sessionId.uuidString)")
            throw StudySessionTrackerLocalError.pauseNotFound
        }

        guard openIndexes.count == 1 else {
            logger.error("Found multiple open pauses for study session \(session.sessionId.uuidString)")
            throw StudySessionTrackerLocalError.multipleOpenPausesFound
        }

        guard openIndex == session.pauses.indices.last else {
            logger.error("Open pause is not latest for study session \(session.sessionId.uuidString)")
            throw StudySessionTrackerLocalError.openPauseIsNotLatest
        }

        return openIndex
    }

    private func persist(_ session: LocalStudySession, userId: UUID) async throws(StudySessionTrackerLocalError) {
        do {
            let data = try await MainActor.run {
                try JSONEncoder().encode(session)
            }
            userDefaults.set(data, forKey: key(for: userId))
            activeSessionsByUser[userId] = session
        } catch {
            logger.error("Failed to persist study session \(session.sessionId.uuidString): \(error.localizedDescription)")
            throw StudySessionTrackerLocalError.failedToPersistSession
        }
    }

    private func key(for userId: UUID) -> String {
        "\(key).\(userId.uuidString)"
    }
    
    private func restore(userId: UUID) async {
        restoreStatesByUser[userId] = .restoring
        let scopedKey = key(for: userId)

        guard let data = userDefaults.data(forKey: scopedKey) else {
            activeSessionsByUser[userId] = nil
            restoreStatesByUser[userId] = .restored
            emitSessionChanges(for: userId)
            logger.debug("No active study session found to restore")
            return
        }

        let session = await MainActor.run {
            try? JSONDecoder().decode(LocalStudySession.self, from: data)
        }
        activeSessionsByUser[userId] = session
        restoreStatesByUser[userId] = .restored
        emitSessionChanges(for: userId)
        logger.info("Restored active study session")
    }

    private func emitSessionChanges(for userId: UUID) {
        let session = activeSessionsByUser[userId]
        sessionChangeContinuationsByUser[userId]?.values.forEach { $0.yield(session) }
    }

    private func removeSessionContinuation(streamId: UUID, userId: UUID) {
        sessionChangeContinuationsByUser[userId]?[streamId] = nil
        if sessionChangeContinuationsByUser[userId]?.isEmpty == true {
            sessionChangeContinuationsByUser[userId] = nil
        }
    }
}

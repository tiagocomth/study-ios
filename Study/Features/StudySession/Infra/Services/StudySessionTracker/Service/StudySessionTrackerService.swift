//
//  StudySessionTrackerService.swift
//  Study
//

import Foundation

actor StudySessionTrackerService: StudySessionTrackerServiceProtocol {
    private(set) var activeSession: LocalStudySession?

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

    func getActiveSession() -> LocalStudySession? {
        activeSession
    }

    func restore() async {
        guard let data = userDefaults.data(forKey: key) else {
            activeSession = nil
            logger.debug("No active study session found to restore")
            return
        }

        activeSession = await MainActor.run {
            try? JSONDecoder().decode(LocalStudySession.self, from: data)
        }
        logger.info("Restored active study session")
    }

    func start(categoryId: UUID) async throws(StudySessionTrackerError) -> StudySessionTrackerAction {
        if let activeSession, activeSession.state != .finished {
            logger.error("Failed to start study session: active session already exists")
            throw StudySessionTrackerError.activeSessionAlreadyExists
        }

        let session = LocalStudySession(
            sessionId: makeId(),
            categoryId: categoryId,
            startDate: now(),
            endDate: nil,
            state: .running,
            pauses: []
        )

        try await persist(session)
        logger.info("Started study session \(session.sessionId.uuidString)")

        return .started(
            StartStudySessionDTO(
                sessionId: session.sessionId,
                startDate: session.startDate,
                categoryId: session.categoryId
            )
        )
    }

    func pause() async throws(StudySessionTrackerError) -> StudySessionTrackerAction {
        var session = try requireActiveSession()

        switch session.state {
        case .running:
            break
        case .paused:
            logger.error("Failed to pause study session: session is already paused")
            throw StudySessionTrackerError.sessionAlreadyPaused
        case .finished:
            logger.error("Failed to pause study session: session is already finished")
            throw StudySessionTrackerError.sessionAlreadyFinished
        }

        let pause = LocalStudyPause(
            pauseId: makeId(),
            startedAt: now(),
            endedAt: nil
        )

        session.pauses.append(pause)
        session.state = .paused

        try await persist(session)
        logger.info("Paused study session \(session.sessionId.uuidString) with pause \(pause.pauseId.uuidString)")

        return .paused(
            PauseStudySessionDTO(
                pauseId: pause.pauseId,
                startedAt: pause.startedAt
            )
        )
    }

    func resume() async throws(StudySessionTrackerError) -> StudySessionTrackerAction {
        var session = try requireActiveSession()

        switch session.state {
        case .running:
            logger.error("Failed to resume study session: session is not paused")
            throw StudySessionTrackerError.sessionIsNotPaused
        case .paused:
            break
        case .finished:
            logger.error("Failed to resume study session: session is already finished")
            throw StudySessionTrackerError.sessionAlreadyFinished
        }

        let pauseIndex = try openPauseIndex(in: session)

        let endedAt = now()
        session.pauses[pauseIndex].endedAt = endedAt
        session.state = .running

        try await persist(session)
        logger.info("Resumed study session \(session.sessionId.uuidString)")

        return .resumed(
            ResumeStudySessionDTO(
                endedAt: endedAt
            )
        )
    }

    func finish() async throws(StudySessionTrackerError) -> StudySessionTrackerAction {
        var session = try requireActiveSession()

        guard session.state != .finished else {
            logger.error("Failed to finish study session: session is already finished")
            throw StudySessionTrackerError.sessionAlreadyFinished
        }

        let endDate = now()

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

        try await persist(session)
        logger.info("Finished study session \(session.sessionId.uuidString)")

        let endDTO = EndStudySessionDTO(
            endDate: endDate
        )

        if let closePauseDTO {
            return .resumedAndFinished(resume: closePauseDTO, end: endDTO)
        }

        return .finished(endDTO)
    }

    func clear() {
        userDefaults.removeObject(forKey: key)
        activeSession = nil
        logger.info("Cleared active study session")
    }

    private func requireActiveSession() throws(StudySessionTrackerError) -> LocalStudySession {
        guard let activeSession else {
            logger.error("Failed to read active study session: session not found")
            throw StudySessionTrackerError.sessionNotFound
        }

        return activeSession
    }

    private func openPauseIndex(in session: LocalStudySession) throws(StudySessionTrackerError) -> Int {
        let openIndexes = session.pauses.indices.filter { session.pauses[$0].endedAt == nil }

        guard let openIndex = openIndexes.first else {
            logger.error("Failed to find open pause for study session \(session.sessionId.uuidString)")
            throw StudySessionTrackerError.pauseNotFound
        }

        guard openIndexes.count == 1 else {
            logger.error("Found multiple open pauses for study session \(session.sessionId.uuidString)")
            throw StudySessionTrackerError.multipleOpenPausesFound
        }

        guard openIndex == session.pauses.indices.last else {
            logger.error("Open pause is not latest for study session \(session.sessionId.uuidString)")
            throw StudySessionTrackerError.openPauseIsNotLatest
        }

        return openIndex
    }

    private func persist(_ session: LocalStudySession) async throws(StudySessionTrackerError) {
        do {
            let data = try await MainActor.run {
                try JSONEncoder().encode(session)
            }
            userDefaults.set(data, forKey: key)
            activeSession = session
        } catch {
            logger.error("Failed to persist study session \(session.sessionId.uuidString): \(error.localizedDescription)")
            throw StudySessionTrackerError.failedToPersistSession
        }
    }
}

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

    init(
        userDefaults: UserDefaults = .standard,
        key: String = AppKeys.activeStudySession.rawValue,
        now: @escaping @Sendable () -> Date = { Date() },
        makeId: @escaping @Sendable () -> UUID = { UUID() }
    ) {
        self.userDefaults = userDefaults
        self.key = key
        self.now = now
        self.makeId = makeId
    }

    func getActiveSession() -> LocalStudySession? {
        activeSession
    }

    func restore() async {
        guard let data = userDefaults.data(forKey: key) else {
            activeSession = nil
            return
        }

        activeSession = await MainActor.run {
            try? JSONDecoder().decode(LocalStudySession.self, from: data)
        }
    }

    func start(categoryId: String?) async throws(StudySessionTrackerError) -> StudySessionTrackerAction {
        if let activeSession, activeSession.state != .finished {
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
            throw StudySessionTrackerError.sessionAlreadyPaused
        case .finished:
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

        return .paused(
            PauseStudySessionDTO(
                sessionId: session.sessionId,
                pauseId: pause.pauseId,
                startedAt: pause.startedAt
            )
        )
    }

    func resume() async throws(StudySessionTrackerError) -> StudySessionTrackerAction {
        var session = try requireActiveSession()

        switch session.state {
        case .running:
            throw StudySessionTrackerError.sessionIsNotPaused
        case .paused:
            break
        case .finished:
            throw StudySessionTrackerError.sessionAlreadyFinished
        }

        let pauseIndex = try openPauseIndex(in: session)

        let endedAt = now()
        session.pauses[pauseIndex].endedAt = endedAt
        session.state = .running

        try await persist(session)

        return .resumed(
            ResumeStudySessionDTO(
                sessionId: session.sessionId,
                endedAt: endedAt
            )
        )
    }

    func finish() async throws(StudySessionTrackerError) -> StudySessionTrackerAction {
        var session = try requireActiveSession()

        guard session.state != .finished else {
            throw StudySessionTrackerError.sessionAlreadyFinished
        }

        let endDate = now()

        var closePauseDTO: ResumeStudySessionDTO?

        if session.state == .paused {
            let pauseIndex = try openPauseIndex(in: session)
            
            session.pauses[pauseIndex].endedAt = endDate
            closePauseDTO = ResumeStudySessionDTO(
                sessionId: session.sessionId,
                endedAt: endDate
            )
        }

        session.endDate = endDate
        session.state = .finished

        try await persist(session)

        let endDTO = EndStudySessionDTO(
            sessionId: session.sessionId,
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
    }

    private func requireActiveSession() throws(StudySessionTrackerError) -> LocalStudySession {
        guard let activeSession else {
            throw StudySessionTrackerError.sessionNotFound
        }

        return activeSession
    }

    private func openPauseIndex(in session: LocalStudySession) throws(StudySessionTrackerError) -> Int {
        let openIndexes = session.pauses.indices.filter { session.pauses[$0].endedAt == nil }

        guard let openIndex = openIndexes.first else {
            throw StudySessionTrackerError.pauseNotFound
        }

        guard openIndexes.count == 1 else {
            throw StudySessionTrackerError.multipleOpenPausesFound
        }

        guard openIndex == session.pauses.indices.last else {
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
            throw StudySessionTrackerError.failedToPersistSession
        }
    }
}

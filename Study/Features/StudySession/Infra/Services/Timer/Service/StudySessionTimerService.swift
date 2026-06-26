//
//  StudySessionTimerService.swift
//  Study
//

import Foundation

final class StudySessionTimerService: StudySessionTimerServiceProtocol {
    private let now: @Sendable () -> Date
    private let tickIntervalNanoseconds: UInt64

    init(
        now: @escaping @Sendable () -> Date = { Date() },
        tickIntervalNanoseconds: UInt64 = 1_000_000_000
    ) {
        self.now = now
        self.tickIntervalNanoseconds = tickIntervalNanoseconds
    }

    func timerStates(
        mode: StudySessionTimerMode,
        sessionChanges: AsyncStream<LocalStudySession?>
    ) -> AsyncStream<StudySessionTimerState> {
        AsyncStream { continuation in
            let task = Task {
                let sessionBox = SessionStateBox()

                let sessionTask = Task {
                    for await session in sessionChanges {
                        await sessionBox.set(session)
                        continuation.yield(makeState(mode: mode, session: session))
                    }
                }

                continuation.yield(makeState(mode: mode, session: nil))

                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: tickIntervalNanoseconds)
                    let currentSession = await sessionBox.get()
                    continuation.yield(makeState(mode: mode, session: currentSession))
                }

                sessionTask.cancel()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}

private actor SessionStateBox {
    private var session: LocalStudySession?

    func set(_ session: LocalStudySession?) {
        self.session = session
    }

    func get() -> LocalStudySession? {
        session
    }
}

private extension StudySessionTimerService {
    func makeState(mode: StudySessionTimerMode, session: LocalStudySession?) -> StudySessionTimerState {
        let elapsedSeconds = session.map(elapsedSeconds(for:)) ?? 0
        
        let isRunning = session?.state == .running

        switch mode {
        case .stopwatch:
            return StudySessionTimerState(
                mode: mode,
                elapsedSeconds: elapsedSeconds,
                remainingSeconds: nil,
                isRunning: isRunning
            )

        case .countdown(let durationSeconds):
            return StudySessionTimerState(
                mode: mode,
                elapsedSeconds: elapsedSeconds,
                remainingSeconds: max(durationSeconds - elapsedSeconds, 0),
                isRunning: isRunning
            )
        }
    }

    func elapsedSeconds(for session: LocalStudySession) -> Int {
        let effectiveEndDate = effectiveEndDate(for: session)
        let totalDuration = max(effectiveEndDate.timeIntervalSince(session.startDate), 0)
        let pausedDuration = session.pauses.reduce(into: 0.0) { partialResult, pause in
            let pauseEndDate = pause.endedAt ?? effectiveEndDate
            partialResult += max(pauseEndDate.timeIntervalSince(pause.startedAt), 0)
        }

        return max(Int(totalDuration - pausedDuration), 0)
    }

    func effectiveEndDate(for session: LocalStudySession) -> Date {
        session.endDate ?? now()
    }
}

//
//  StudySessionTimerServiceProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionTimerServiceProtocol {
    func timerStates(
        mode: StudySessionTimerMode,
        sessionChanges: AsyncStream<LocalStudySession?>
    ) -> AsyncStream<StudySessionTimerState>
}

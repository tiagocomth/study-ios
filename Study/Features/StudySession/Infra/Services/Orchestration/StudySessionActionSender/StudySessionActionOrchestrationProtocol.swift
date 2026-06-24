//
//  StudySessionActionSenderOrchestrationProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionActionOrchestrationProtocol {
    func send(_ action: StudySessionTrackerAction) async throws
}

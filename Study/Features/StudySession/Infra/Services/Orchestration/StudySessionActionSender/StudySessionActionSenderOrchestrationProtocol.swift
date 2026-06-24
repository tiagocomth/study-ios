//
//  StudySessionActionSenderOrchestrationProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionActionSenderOrchestrationProtocol {
    func send(_ action: StudySessionTrackerAction) async throws
}

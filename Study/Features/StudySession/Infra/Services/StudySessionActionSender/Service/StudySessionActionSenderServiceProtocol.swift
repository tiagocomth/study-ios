//
//  StudySessionActionSenderServiceProtocol.swift
//  Study
//

import Foundation

nonisolated protocol StudySessionActionSenderServiceProtocol {
    func send(_ action: StudySessionTrackerAction) async throws
}

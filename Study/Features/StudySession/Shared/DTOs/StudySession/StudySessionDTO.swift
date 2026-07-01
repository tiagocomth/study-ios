//
//  StudySessionDTO.swift
//  Study
//

import Foundation

struct StudySessionDTO: Decodable, Equatable {
    let sessionId: String
    let userId: String
    let categoryId: String
    let startedAt: String
    let endedAt: String?
}

extension StudySessionDTO {
    var isActiveBackendSession: Bool {
        endedAt?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }

    func toLocalStudySession() -> LocalStudySession? {
        guard
            let sessionId = UUID(uuidString: sessionId),
            let categoryId = UUID(uuidString: categoryId),
            let startDate = ISO8601DateParser().parse(startedAt)
        else {
            return nil
        }

        return LocalStudySession(
            sessionId: sessionId,
            categoryId: categoryId,
            startDate: startDate,
            endDate: nil,
            expectedEndDate: nil,
            countdownDurationSeconds: nil,
            state: .running,
            pauses: []
        )
    }
}

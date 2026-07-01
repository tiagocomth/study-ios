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
    let duration: Int?
    let category: StudyCategoryDTO?
    let pauses: [StudySessionPauseDTO]
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

        let endDate: Date? = endedAt.flatMap { value in
            let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedValue.isEmpty == false else { return nil }
            return ISO8601DateParser().parse(trimmedValue)
        }
        let pauses = pauses.compactMap(\.toLocalPause)
        let state: StudySessionState

        if endDate != nil {
            state = .finished
        } else if pauses.contains(where: { $0.endedAt == nil }) {
            state = .paused
        } else {
            state = .running
        }

        return LocalStudySession(
            sessionId: sessionId,
            categoryId: categoryId,
            startDate: startDate,
            endDate: endDate,
            expectedEndDate: nil,
            countdownDurationSeconds: nil,
            state: state,
            pauses: pauses
        )
    }
}

struct StudyCategoryDTO: Decodable, Equatable {
    let categoryId: String
    let userId: String
    let name: String
    let createdAt: String
    let isDeleted: Bool
}

struct StudySessionPauseDTO: Decodable, Equatable {
    let pauseId: String
    let studySessionId: String
    let startedAt: String
    let endedAt: String?
}

private extension StudySessionPauseDTO {
    var toLocalPause: LocalStudyPause? {
        guard
            let pauseId = UUID(uuidString: pauseId),
            let startedAt = ISO8601DateParser().parse(startedAt)
        else {
            return nil
        }

        let endedAt: Date? = endedAt.flatMap { value in
            let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedValue.isEmpty == false else { return nil }
            return ISO8601DateParser().parse(trimmedValue)
        }

        return LocalStudyPause(
            pauseId: pauseId,
            startedAt: startedAt,
            endedAt: endedAt
        )
    }
}

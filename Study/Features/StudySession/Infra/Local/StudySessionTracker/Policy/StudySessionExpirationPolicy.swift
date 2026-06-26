//
//  StudySessionExpirationPolicy.swift
//  Study
//

import Foundation

struct StudySessionExpirationPolicy {
    static let maxActiveDuration: TimeInterval = 24 * 60 * 60

    static func shouldExpire(_ session: LocalStudySession, now: Date) -> Bool {
        now.timeIntervalSince(session.startDate) >= maxActiveDuration
    }
}

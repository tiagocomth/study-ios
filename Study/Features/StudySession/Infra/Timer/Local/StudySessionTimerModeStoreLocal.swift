//
//  StudySessionTimerModeStoreLocal.swift
//  Study
//

import Foundation

actor StudySessionTimerModeStoreLocal: StudySessionTimerModeStoreLocalProtocol {
    private var modesByUser: [UUID: StudySessionTimerMode] = [:]
    private var restoreStatesByUser: [UUID: RestoreState] = [:]

    private let userDefaults: UserDefaults
    private let key: String

    init(
        userDefaults: UserDefaults = .standard,
        key: String = AppKeys.studySessionTimerMode.rawValue
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func restoreState(for userId: UUID) -> RestoreState {
        restoreStatesByUser[userId] ?? .notStarted
    }

    func ensureRestored(userId: UUID) async {
        guard restoreState(for: userId) != .restored else { return }
        await restore(userId: userId)
    }

    func getMode(userId: UUID) async -> StudySessionTimerMode? {
        await ensureRestored(userId: userId)
        return modesByUser[userId]
    }

    func saveMode(_ mode: StudySessionTimerMode, userId: UUID) async {
        await ensureRestored(userId: userId)
        modesByUser[userId] = mode

        let data = await MainActor.run {
            try? JSONEncoder().encode(mode)
        }
        guard (data != nil) else { return }
        
        userDefaults.set(data, forKey: scopedKey(userId: userId))
    }

    func clear(userId: UUID) async {
        await ensureRestored(userId: userId)
        modesByUser[userId] = nil
        userDefaults.removeObject(forKey: scopedKey(userId: userId))
    }
}

private extension StudySessionTimerModeStoreLocal {
    func restore(userId: UUID) async {
        restoreStatesByUser[userId] = .restoring

        guard let data = userDefaults.data(forKey: scopedKey(userId: userId)),
              let mode = try? JSONDecoder().decode(StudySessionTimerMode.self, from: data) else {
            modesByUser[userId] = nil
            restoreStatesByUser[userId] = .restored
            return
        }

        modesByUser[userId] = mode
        restoreStatesByUser[userId] = .restored
    }

    func scopedKey(userId: UUID) -> String {
        "\(key).\(userId.uuidString)"
    }
}

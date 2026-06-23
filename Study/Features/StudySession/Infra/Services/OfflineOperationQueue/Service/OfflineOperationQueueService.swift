//
//  OfflineOperationQueueService.swift
//  Study
//

import Foundation

actor OfflineOperationQueueService: OfflineOperationQueueServiceProtocol {
    private var pendingOperations: [PendingOfflineOperation] = []

    private let userDefaults: UserDefaults
    private let key: String
    private let now: @Sendable () -> Date

    init(
        userDefaults: UserDefaults = .standard,
        key: String = AppKeys.pendingOfflineOperations.rawValue,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.userDefaults = userDefaults
        self.key = key
        self.now = now
    }

    func restore() async {
        guard let data = userDefaults.data(forKey: key) else {
            pendingOperations = []
            return
        }

        pendingOperations = await MainActor.run {
            (try? JSONDecoder().decode([PendingOfflineOperation].self, from: data)) ?? []
        }
    }

    func enqueue(_ operation: PendingOfflineOperation) async throws(OfflineOperationQueueError) {
        var updatedOperations = pendingOperations
        updatedOperations.append(operation)

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
    }

    func enqueue(_ operations: [PendingOfflineOperation]) async throws(OfflineOperationQueueError) {
        guard !operations.isEmpty else { return }

        var updatedOperations = pendingOperations
        updatedOperations.append(contentsOf: operations)

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
    }

    func peek() -> PendingOfflineOperation? {
        pendingOperations.first
    }

    func allPending() -> [PendingOfflineOperation] {
        pendingOperations
    }

    func markFirstSucceeded(_ id: UUID) async throws(OfflineOperationQueueError) {
        try validateFirstOperation(id)

        var updatedOperations = pendingOperations
        updatedOperations.removeFirst()

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
    }

    func markFirstFailed(_ id: UUID) async throws(OfflineOperationQueueError) {
        try validateFirstOperation(id)

        var updatedOperations = pendingOperations
        updatedOperations[0].attemptCount += 1
        updatedOperations[0].lastAttemptAt = now()

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
    }

    private func validateFirstOperation(_ id: UUID) throws(OfflineOperationQueueError) {
        guard let firstOperation = pendingOperations.first else {
            throw OfflineOperationQueueError.queueIsEmpty
        }

        guard firstOperation.id == id else {
            throw OfflineOperationQueueError.operationIsNotFirst
        }
    }

    private func persist(_ operations: [PendingOfflineOperation]) async throws(OfflineOperationQueueError) {
        do {
            let data = try await MainActor.run {
                try JSONEncoder().encode(operations)
            }
            userDefaults.set(data, forKey: key)
        } catch {
            throw OfflineOperationQueueError.failedToPersistOperations
        }
    }
}

//
//  OfflineOperationQueueLocal.swift
//  Study
//

import Foundation

actor OfflineOperationQueueLocal: OfflineOperationQueueLocalProtocol {
    private var pendingOperations: [PendingOfflineOperation] = []

    private let userDefaults: UserDefaults
    private let key: String
    private let now: @Sendable () -> Date
    private let logger: DomainLogging

    init(
        userDefaults: UserDefaults = .standard,
        key: String = AppKeys.pendingOfflineOperations.rawValue,
        now: @escaping @Sendable () -> Date = { Date() },
        logger: DomainLogging = OfflineOperationQueueLogger()
    ) {
        self.userDefaults = userDefaults
        self.key = key
        self.now = now
        self.logger = logger
    }

    func restore() async {
        guard let data = userDefaults.data(forKey: key) else {
            pendingOperations = []
            logger.debug("No pending offline operations found to restore")
            return
        }

        pendingOperations = await MainActor.run {
            (try? JSONDecoder().decode([PendingOfflineOperation].self, from: data)) ?? []
        }
        logger.info("Restored \(pendingOperations.count) pending offline operations")
    }

    func enqueue(_ operation: PendingOfflineOperation) async throws(OfflineOperationQueueLocalError) {
        var updatedOperations = pendingOperations
        updatedOperations.append(operation)

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
        logger.info("Enqueued offline operation \(operation.id.uuidString)")
    }

    func enqueue(_ operations: [PendingOfflineOperation]) async throws(OfflineOperationQueueLocalError) {
        guard !operations.isEmpty else { return }

        var updatedOperations = pendingOperations
        updatedOperations.append(contentsOf: operations)

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
        logger.info("Enqueued \(operations.count) offline operations")
    }

    func peek() -> PendingOfflineOperation? {
        pendingOperations.first
    }

    func allPending() -> [PendingOfflineOperation] {
        pendingOperations
    }

    func markFirstSucceeded(_ id: UUID) async throws(OfflineOperationQueueLocalError) {
        try validateFirstOperation(id)

        var updatedOperations = pendingOperations
        updatedOperations.removeFirst()

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
        logger.info("Marked first offline operation \(id.uuidString) as succeeded")
    }

    func markFirstFailed(_ id: UUID) async throws(OfflineOperationQueueLocalError) {
        try validateFirstOperation(id)

        var updatedOperations = pendingOperations
        updatedOperations[0].attemptCount += 1
        updatedOperations[0].lastAttemptAt = now()

        try await persist(updatedOperations)
        pendingOperations = updatedOperations
        logger.info("Marked first offline operation \(id.uuidString) as failed")
    }

    private func validateFirstOperation(_ id: UUID) throws(OfflineOperationQueueLocalError) {
        guard let firstOperation = pendingOperations.first else {
            logger.error("Failed to update offline operation \(id.uuidString): queue is empty")
            throw OfflineOperationQueueLocalError.queueIsEmpty
        }

        guard firstOperation.id == id else {
            logger.error("Failed to update offline operation \(id.uuidString): operation is not first")
            throw OfflineOperationQueueLocalError.operationIsNotFirst
        }
    }

    private func persist(_ operations: [PendingOfflineOperation]) async throws(OfflineOperationQueueLocalError) {
        do {
            let data = try await MainActor.run {
                try JSONEncoder().encode(operations)
            }
            userDefaults.set(data, forKey: key)
        } catch {
            logger.error("Failed to persist offline operations: \(error.localizedDescription)")
            throw OfflineOperationQueueLocalError.failedToPersistOperations
        }
    }
}

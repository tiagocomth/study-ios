//
//  OfflineOperationQueueLocal.swift
//  Study
//

import Foundation

actor OfflineOperationQueueLocal: OfflineOperationQueueLocalProtocol {
    private var pendingOperationsByUser: [UUID: [PendingOfflineOperation]] = [:]
    private var restoreStatesByUser: [UUID: RestoreState] = [:]

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

    func restoreState(for userId: UUID) -> RestoreState {
        restoreStatesByUser[userId] ?? .notStarted
    }

    func ensureRestored(userId: UUID) async {
        guard restoreState(for: userId) != .restored else { return }
        await restore(userId: userId)
    }

    func enqueue(_ operation: PendingOfflineOperation, userId: UUID) async throws(OfflineOperationQueueLocalError) {
        await ensureRestored(userId: userId)
        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations.append(operation)

        pendingOperationsByUser[userId] = updatedOperations
        try persist(userId: userId)
        logger.info("Enqueued offline operation \(operation.id.uuidString)")
    }

    func enqueue(_ operations: [PendingOfflineOperation], userId: UUID) async throws(OfflineOperationQueueLocalError) {
        await ensureRestored(userId: userId)
        guard !operations.isEmpty else { return }

        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations.append(contentsOf: operations)

        pendingOperationsByUser[userId] = updatedOperations
        try persist(userId: userId)
        logger.info("Enqueued \(operations.count) offline operations")
    }

    func peek(userId: UUID) -> PendingOfflineOperation? {
        pendingOperationsByUser[userId]?.first
    }

    func allPending(userId: UUID) -> [PendingOfflineOperation] {
        pendingOperationsByUser[userId] ?? []
    }

    func markFirstSucceeded(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError) {
        await ensureRestored(userId: userId)
        try validateFirstOperation(id, userId: userId)

        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations.removeFirst()

        pendingOperationsByUser[userId] = updatedOperations
        try persist(userId: userId)
        logger.info("Marked first offline operation \(id.uuidString) as succeeded")
    }

    func markFirstFailed(_ id: UUID, userId: UUID) async throws(OfflineOperationQueueLocalError) {
        await ensureRestored(userId: userId)
        try validateFirstOperation(id, userId: userId)

        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations[0].attemptCount += 1
        updatedOperations[0].lastAttemptAt = now()

        pendingOperationsByUser[userId] = updatedOperations
        try persist(userId: userId)
        logger.info("Marked first offline operation \(id.uuidString) as failed")
    }

    func clear(userId: UUID) async throws(OfflineOperationQueueLocalError) {
        await ensureRestored(userId: userId)
        pendingOperationsByUser[userId] = []
        try persist(userId: userId)
        logger.info("Cleared offline operation queue for user \(userId.uuidString)")
    }

    private func validateFirstOperation(_ id: UUID, userId: UUID) throws(OfflineOperationQueueLocalError) {
        guard let firstOperation = pendingOperationsByUser[userId]?.first else {
            logger.error("Failed to update offline operation \(id.uuidString): queue is empty")
            throw OfflineOperationQueueLocalError.queueIsEmpty
        }

        guard firstOperation.id == id else {
            logger.error("Failed to update offline operation \(id.uuidString): operation is not first")
            throw OfflineOperationQueueLocalError.operationIsNotFirst
        }
    }

    private func persist(userId: UUID) throws(OfflineOperationQueueLocalError) {
        do {
            let data = try JSONEncoder().encode(pendingOperationsByUser[userId] ?? [])
            
            userDefaults.set(data, forKey: key(for: userId))
        } catch {
            logger.error("Failed to persist offline operations: \(error.localizedDescription)")
            throw OfflineOperationQueueLocalError.failedToPersistOperations
        }
    }

    private func key(for userId: UUID) -> String {
        "\(key).\(userId.uuidString)"
    }
    
    private func restore(userId: UUID) async {
        restoreStatesByUser[userId] = .restoring

        guard let data = userDefaults.data(forKey: key(for: userId)) else {
            pendingOperationsByUser[userId] = []
            restoreStatesByUser[userId] = .restored
            logger.debug("No pending offline operations found to restore")
            return
        }

        guard let restoredOperations = try? JSONDecoder().decode([PendingOfflineOperation].self, from: data) else {
            restoreStatesByUser[userId] = .failed
            logger.error("Failed to decode pending offline operations during restore")
            return
        }

        pendingOperationsByUser[userId] = restoredOperations
        restoreStatesByUser[userId] = .restored
        
        logger.info("Restored \(restoredOperations.count) pending offline operations")
    }
}

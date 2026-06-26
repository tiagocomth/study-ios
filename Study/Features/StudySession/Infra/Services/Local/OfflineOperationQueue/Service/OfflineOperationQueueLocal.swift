//
//  OfflineOperationQueueLocal.swift
//  Study
//

import Foundation

actor OfflineOperationQueueLocal: OfflineOperationQueueLocalProtocol {
    private var pendingOperationsByUser: PendingOperationsByUser = [:]

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
            pendingOperationsByUser = [:]
            logger.debug("No pending offline operations found to restore")
            return
        }

        pendingOperationsByUser = (try? JSONDecoder().decode(PendingOperationsByUser.self, from: data)) ?? [:]
        
        let pendingCount = pendingOperationsByUser.values.reduce(0) { $0 + $1.count }
        logger.info("Restored \(pendingCount) pending offline operations")
    }

    func enqueue(_ operation: PendingOfflineOperation, userId: UUID) throws(OfflineOperationQueueLocalError) {
        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations.append(operation)

        pendingOperationsByUser[userId] = updatedOperations
        try persist()
        logger.info("Enqueued offline operation \(operation.id.uuidString)")
    }

    func enqueue(_ operations: [PendingOfflineOperation], userId: UUID) throws(OfflineOperationQueueLocalError) {
        guard !operations.isEmpty else { return }

        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations.append(contentsOf: operations)

        pendingOperationsByUser[userId] = updatedOperations
        try persist()
        logger.info("Enqueued \(operations.count) offline operations")
    }

    func peek(userId: UUID) -> PendingOfflineOperation? {
        pendingOperationsByUser[userId]?.first
    }

    func allPending(userId: UUID) -> [PendingOfflineOperation] {
        pendingOperationsByUser[userId] ?? []
    }

    func markFirstSucceeded(_ id: UUID, userId: UUID) throws(OfflineOperationQueueLocalError) {
        try validateFirstOperation(id, userId: userId)

        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations.removeFirst()

        pendingOperationsByUser[userId] = updatedOperations
        try persist()
        logger.info("Marked first offline operation \(id.uuidString) as succeeded")
    }

    func markFirstFailed(_ id: UUID, userId: UUID) throws(OfflineOperationQueueLocalError) {
        try validateFirstOperation(id, userId: userId)

        var updatedOperations = pendingOperationsByUser[userId] ?? []
        updatedOperations[0].attemptCount += 1
        updatedOperations[0].lastAttemptAt = now()

        pendingOperationsByUser[userId] = updatedOperations
        try persist()
        logger.info("Marked first offline operation \(id.uuidString) as failed")
    }

    func clear(userId: UUID) throws(OfflineOperationQueueLocalError) {
        pendingOperationsByUser[userId] = []
        try persist()
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

    private func persist() throws(OfflineOperationQueueLocalError) {
        do {
            let data = try JSONEncoder().encode(pendingOperationsByUser)
            
            userDefaults.set(data, forKey: key)
        } catch {
            logger.error("Failed to persist offline operations: \(error.localizedDescription)")
            throw OfflineOperationQueueLocalError.failedToPersistOperations
        }
    }
}

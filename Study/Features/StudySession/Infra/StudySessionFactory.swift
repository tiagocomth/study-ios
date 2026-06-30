//
//  StudySessionFactory.swift
//  Study
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class StudySessionFactory {
    weak var coordinator: StudySessionCoordinator?

    private let userSession: UserSessionService
    private let categoryLocal: CategoryStoreLocalProtocol
    private let studySessionTracker: StudySessionTrackerLocalProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let operationSyncService: OperationSyncServiceProtocol
    private let categorySyncService: CategorySyncServiceProtocol
    private let timerModeStore: StudySessionTimerModeStoreLocalProtocol
    private let timerService: StudySessionTimerServiceProtocol
    private let categoryManager: CategoryManagerProtocol
    private let studySessionManager: StudySessionManagerProtocol
    private let now: @Sendable () -> Date
    private let makeId: @Sendable () -> UUID

    init(
        apiClient: APIClientProtocol,
        userSession: UserSessionService,
        modelContainer: ModelContainer,
        now: @escaping @Sendable () -> Date = { Date() },
        makeId: @escaping @Sendable () -> UUID = { UUID() }
    ) {
        self.userSession = userSession
        self.now = now
        self.makeId = makeId

        let currentUserId = { userSession.currentUserId }
        let categoryAPI = CategoryAPI(apiClient: apiClient)
        let studySessionAPI = StudySessionAPI(apiClient: apiClient)
        let categoryLocal = CategoryStoreLocal(context: modelContainer.mainContext)
        let studySessionTracker = StudySessionTrackerLocal(now: now, makeId: makeId)
        let offlineOperationQueue = OfflineOperationQueueLocal(now: now)
        let operationManager = OperationManager(
            offlineOperationQueue: offlineOperationQueue,
            makeId: makeId,
            now: now
        )
        let offlineOperationSender = OfflineOperationSender(
            studySessionAPI: studySessionAPI,
            categoryAPI: categoryAPI
        )
        let operationSyncService = OperationSyncService(
            offlineOperationSender: offlineOperationSender,
            offlineOperationQueue: offlineOperationQueue,
            currentUserId: currentUserId
        )
        let categorySyncService = CategorySyncService(
            categoryAPI: categoryAPI,
            categoryLocal: categoryLocal,
            offlineOperationQueue: offlineOperationQueue
        )
        let timerModeStore = StudySessionTimerModeStoreLocal()
        let timerService = StudySessionTimerService(now: now)
        let categoryManager = CategoryManager(
            categoryAPI: categoryAPI,
            categoryLocal: categoryLocal,
            operationManager: operationManager,
            currentUserId: currentUserId,
            now: now
        )
        let studySessionManager = StudySessionManager(
            studySessionTracker: studySessionTracker,
            studySessionAPI: studySessionAPI,
            operationManager: operationManager,
            currentUserId: currentUserId
        )

        self.categoryLocal = categoryLocal
        self.studySessionTracker = studySessionTracker
        self.offlineOperationQueue = offlineOperationQueue
        self.operationSyncService = operationSyncService
        self.categorySyncService = categorySyncService
        self.timerModeStore = timerModeStore
        self.timerService = timerService
        self.categoryManager = categoryManager
        self.studySessionManager = studySessionManager
    }

    func makeStudySessionView() -> some View {
        let viewModel = makeStudySessionViewModel()
        return StudySessionView(viewModel: viewModel)
    }

    func makeCategoryFormView() -> some View {
        let viewModel = makeCategoryFormViewModel()
        return StudySessionCategoryFormView(viewModel: viewModel)
    }

    func restoreLocalState() async {
        guard let userId = userSession.currentUserId else { return }

        await categoryLocal.ensureRestored(userId: userId)
        await studySessionTracker.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)
    }

    func syncPendingOperations() async {
        do {
            await restoreLocalState()
            let result = try await operationSyncService.sync()
            try await handleOperationSyncResult(result)
        } catch {
            OfflineOperationQueueLogger().error("Failed to sync study session operations: \(error.localizedDescription)")
        }
    }

    func expireSessionIfNeeded() async {
        guard let userId = userSession.currentUserId else { return }

        await studySessionTracker.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)

        guard await finishExpectedCountdownIfNeeded(userId: userId) == false else { return }

        guard let session = await studySessionTracker.getActiveSession(userId: userId) else { return }
        guard StudySessionExpirationPolicy.shouldExpire(session, now: now()) else { return }

        await studySessionTracker.clear(userId: userId)

        let operation = PendingOfflineOperation(
            id: makeId(),
            createdAt: now(),
            lastAttemptAt: nil,
            attemptCount: 0,
            kind: .deleteStudySession(session.sessionId)
        )

        do {
            try await offlineOperationQueue.enqueue(operation, userId: userId)
            OfflineOperationQueueLogger().info("Expired study session \(session.sessionId.uuidString) and enqueued delete operation")
        } catch {
            OfflineOperationQueueLogger().error("Failed to enqueue delete operation for expired study session \(session.sessionId.uuidString): \(error.localizedDescription)")
        }
    }
}

private extension StudySessionFactory {
    func finishExpectedCountdownIfNeeded(userId: UUID) async -> Bool {
        guard
            let session = await studySessionTracker.getActiveSession(userId: userId),
            session.state == .running,
            let expectedEndDate = session.expectedEndDate,
            expectedEndDate <= now()
        else {
            return false
        }

        do {
            try await studySessionManager.finish(endDate: expectedEndDate)
            await timerModeStore.clear(userId: userId)
            OfflineOperationQueueLogger().info("Finished expired countdown session \(session.sessionId.uuidString)")
            return true
        } catch {
            OfflineOperationQueueLogger().error("Failed to finish expired countdown session \(session.sessionId.uuidString): \(error.localizedDescription)")
            return false
        }
    }

    func makeStudySessionViewModel() -> StudySessionViewModel {
        let viewModel = StudySessionViewModel(worker: makeStudySessionWorker())
        viewModel.coordinator = coordinator
        return viewModel
    }

    func makeCategoryFormViewModel() -> StudySessionCategoryFormViewModel {
        let viewModel = StudySessionCategoryFormViewModel(worker: makeStudySessionWorker())
        viewModel.coordinator = coordinator
        return viewModel
    }

    func makeStudySessionWorker() -> StudySessionWorkerProtocol {
        StudySessionWorker(
            categoryManager: categoryManager,
            studySessionManager: studySessionManager,
            timerModeStore: timerModeStore,
            timerService: timerService,
            currentUserId: { [weak userSession] in userSession?.currentUserId }
        )
    }

    func handleOperationSyncResult(_ result: OperationSyncResult) async throws {
        switch result {
        case .completed:
            guard let userId = userSession.currentUserId else { return }
            try await categorySyncService.refreshFromBackendIfQueueIsEmpty(userId: userId)
        case .stoppedOnFailure:
            OfflineOperationQueueLogger().info("Study session operation sync stopped after a retryable failure")
        case .alreadyRunning:
            OfflineOperationQueueLogger().debug("Study session operation sync skipped because a sync is already running")
        }
    }
}

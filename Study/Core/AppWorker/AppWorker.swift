//
//  AppWorker.swift
//  Study
//
//  Created by Caio Mandarino on 17/06/26.
//

import Foundation
import SwiftData

@MainActor
final class AppWorker {

    /// Single source of truth for the logged-in user, owned by the composition root.
    let userSessionService: UserSessionService

    /// Single configured network client. Injected downstream into the feature
    /// factories/services (instead of each one creating its own).
    let apiClient: APIClientProtocol
    let paymentService: PaymentProtocol

    private let appCoordinator: AppCoordinator
    private let paymentLogger: DomainLogging
    private let modelContainer: ModelContainer
    private let connectivityMonitorService: ConnectivityMonitorServiceProtocol
    private let appLifecycleService: AppLifecycleServiceProtocol
    private let categoryLocal: CategoryStoreLocalProtocol
    private let studySessionTracker: StudySessionTrackerLocalProtocol
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let offlineOperationSender: OfflineOperationSenderRemoteProtocol
    private let operationSyncService: OperationSyncServiceProtocol
    private var appTasks: [Task<Void, Never>]

    init() {
        let session = UserSessionService()
        session.restore()
        self.userSessionService = session
        self.paymentLogger = PaymentLogger()
        self.paymentService = StoreKitPaymentService(logger: paymentLogger)
        self.modelContainer = Self.makeModelContainer()

        // One client for the whole app; reads the current token from the session
        // on every request via the token provider closure.
        self.apiClient = APIClient(
            tokenProvider: TokenProvider { session.token }
        )
        let currentUserId = { session.currentUserId }

        let categoryRemote = CategoryRemote(apiClient: apiClient)
        let studySessionRemote = StudySessionRemote(apiClient: apiClient)
        let categoryLocal = CategoryStoreLocal(context: modelContainer.mainContext)
        let studySessionTracker = StudySessionTrackerLocal()
        let offlineOperationQueue = OfflineOperationQueueLocal()
        let offlineOperationSender = OfflineOperationSenderRemote(studySessionRemoteService: studySessionRemote, categoryService: categoryRemote)
        let operationSyncService = OperationSyncService(
            offlineOperationSender: offlineOperationSender,
            offlineOperationQueue: offlineOperationQueue,
            currentUserId: currentUserId
        )
        
        self.connectivityMonitorService = ConnectivityMonitorService()
        self.appLifecycleService = AppLifecycleService()
        self.categoryLocal = categoryLocal
        self.studySessionTracker = studySessionTracker
        self.offlineOperationQueue = offlineOperationQueue
        self.offlineOperationSender = offlineOperationSender
        self.operationSyncService = operationSyncService
        self.appTasks = []

        // Auto-logout whenever a request comes back 401. `logout()` is
        // `@MainActor`, so hop back to the main actor from the interceptor.
        AuthenticationInterceptor.shared.configure {
            Task { @MainActor in session.logout() }
        }

        self.appCoordinator = AppCoordinator()
        configurePayments()
        configureStudySessionSync()
    }

    func makeAuthCoordinator() -> AuthCoordinator {
        return appCoordinator.makeAuthCoordinator(apiClient: apiClient, session: userSessionService)
    }

    func updateLifecycleState(_ state: AppLifecycleState) {
        appLifecycleService.updateState(state)
    }
    
    deinit {
        //TODO: Fazer os stops tbm
        for task in self.appTasks {
            task.cancel()
        }
    }
}

private extension AppWorker {
    private static func makeModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: StoredStudyCategory.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    private func configurePayments() {
        let paymentTask = Task {
            await paymentService.startTransactionListener { [paymentLogger] event in
                paymentLogger.info("App received payment event: \(event.logDescription)")
                // TODO: implementar o uso do event
                
            }

            await paymentService.refreshEntitlements()
        }
        
        appTasks.append(paymentTask)
    }

    private func configureStudySessionSync() {
        connectivityMonitorService.start()

        Task { [weak self] in
            await self?.restoreLocal()
        }

        let connectivityChanges = connectivityMonitorService.connectivityChanges
        let connectivityTask = Task { [weak self] in
            for await isConnected in connectivityChanges {
                guard isConnected else { continue }
                await self?.syncStudySession()
            }
        }
        
        let stateChanges = appLifecycleService.stateChanges
        let paymentService = paymentService
        
        let appLifeCycleTask = Task { [weak self] in
            for await state in stateChanges {
                guard state == .active else { continue }
                await paymentService.refreshEntitlements()
                await self?.syncStudySession()
            }
        }
        
        appTasks.append(contentsOf: [connectivityTask, appLifeCycleTask])
    }

    private func syncStudySession() async {
        do {
            await restoreLocal()
            let result = try await operationSyncService.sync()
            handleOperationSyncResult(result)
        } catch {
            OfflineOperationQueueLogger().error("Failed to sync study session operations: \(error.localizedDescription)")
        }
    }

    private func handleOperationSyncResult(_ result: OperationSyncResult) {
        switch result {
        case .completed:
            break
        case .failure:
            OfflineOperationQueueLogger().info("Study session operation sync stopped after a retryable failure")
        case .alreadyRunning:
            OfflineOperationQueueLogger().debug("Study session operation sync skipped because a sync is already running")
        }
    }

    private func restoreLocal() async {
        guard let userId = userSessionService.currentUserId else { return }

        await categoryLocal.ensureRestored(userId: userId)
        await studySessionTracker.ensureRestored(userId: userId)
        await offlineOperationQueue.ensureRestored(userId: userId)
    }
    
}

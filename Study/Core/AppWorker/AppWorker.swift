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
    private let offlineOperationQueue: OfflineOperationQueueLocalProtocol
    private let offlineOperationSender: OfflineOperationSenderRemoteProtocol
    private let operationSyncService: OperationSyncServiceProtocol
    private var appTasks: [Task<Void, Never>]

    init() {
        let session = UserSessionService()
        self.userSessionService = session
        self.paymentLogger = PaymentLogger()
        self.paymentService = StoreKitPaymentService(logger: paymentLogger)
        self.modelContainer = Self.makeModelContainer()

        // One client for the whole app; reads the current token from the session
        // on every request via the token provider closure.
        self.apiClient = APIClient(
            tokenProvider: TokenProvider { session.token }
        )

        let categoryRemote = CategoryRemote(apiClient: apiClient)
        let studySessionRemote = StudySessionRemote(apiClient: apiClient)
        let categoryLocal = CategoryStoreLocal(context: modelContainer.mainContext)
        let offlineOperationQueue = OfflineOperationQueueLocal()
        let offlineOperationSender = OfflineOperationSenderRemote(studySessionRemoteService: studySessionRemote, categoryService: categoryRemote)
        let operationSyncService = OperationSyncService(
            offlineOperationSender: offlineOperationSender,
            offlineOperationQueue: offlineOperationQueue,
            categoryRemote: categoryRemote,
            categoryLocal: categoryLocal
        )
        
        self.connectivityMonitorService = ConnectivityMonitorService()
        self.appLifecycleService = AppLifecycleService()
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
        return appCoordinator.makeAuthCoordinator(apiClient: apiClient)
    }

    func updateLifecycleState(_ state: AppLifecycleState) {
        appLifecycleService.updateState(state)
    }
}

private extension AppWorker {
    static func makeModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: StoredStudyCategory.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    func configurePayments() {
        Task {
            await paymentService.startTransactionListener { [paymentLogger] event in
                paymentLogger.info("App received payment event: \(event.logDescription)")
                // TODO: implementar o uso do event
                
            }

            await paymentService.refreshEntitlements()
        }
    }

    func configureStudySessionSync() {
        connectivityMonitorService.start()

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

    func syncStudySession() async {
        do {
            try await operationSyncService.sync()
        } catch {
            OfflineOperationQueueLogger().error("Failed to sync study session operations: \(error.localizedDescription)")
        }
    }
}

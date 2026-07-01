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
    let modelContainer: ModelContainer

    private let appCoordinator: AppCoordinator
    private let paymentLogger: DomainLogging
    private let connectivityMonitorService: ConnectivityMonitorServiceProtocol
    private let appLifecycleService: AppLifecycleServiceProtocol
    private let studySessionFactory: StudySessionFactory
    private var appTasks: [Task<Void, Never>]

    init(modelContainer: ModelContainer) {
        let session = UserSessionService()
        session.restore()
        self.userSessionService = session
        self.modelContainer = modelContainer
        self.paymentLogger = PaymentLogger()
        self.paymentService = StoreKitPaymentService(logger: paymentLogger)

        // One client for the whole app; reads the current token from the session
        // on every request via the token provider closure.
        self.apiClient = APIClient(
            tokenProvider: TokenProvider { session.token }
        )
        self.studySessionFactory = StudySessionFactory(
            apiClient: apiClient,
            userSession: session,
            modelContainer: modelContainer
        )
        
        self.connectivityMonitorService = ConnectivityMonitorService()
        self.appLifecycleService = AppLifecycleService()
        self.appTasks = []

        // Auto-logout whenever a request comes back 401. `logout()` is
        // `@MainActor`, so hop back to the main actor from the interceptor.
        AuthenticationInterceptor.shared.configure {
            Task { @MainActor in session.logout() }
        }

        self.appCoordinator = AppCoordinator()
        if !AppRuntime.isRunningTests {
            configurePayments()
            configureStudySessionSync()
        }
    }

    func makeAuthCoordinator() -> AuthCoordinator {
        return appCoordinator.makeAuthCoordinator(apiClient: apiClient, session: userSessionService)
    }

    func makeStudySessionCoordinator() -> StudySessionCoordinator {
        appCoordinator.makeStudySessionCoordinator(factory: studySessionFactory)
    }

    func makeGroupCoordinator(factory: GroupFactory) -> GroupCoordinator {
        appCoordinator.makeGroupCoordinator(factory: factory)
    }

    func makeProfileCoordinator(factory: ProfileFactory) -> ProfileCoordinator {
        appCoordinator.makeProfileCoordinator(factory: factory)
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
            await self?.studySessionFactory.restoreLocalState()
            await self?.studySessionFactory.expireSessionIfNeeded()
        }

        let connectivityChanges = connectivityMonitorService.connectivityChanges
        let connectivityTask = Task { [weak self] in
            for await isConnected in connectivityChanges.dropFirst() {
                guard isConnected else { continue }
                await self?.studySessionFactory.expireSessionIfNeeded()
                await self?.studySessionFactory.syncPendingOperations()
            }
        }
        
        let stateChanges = appLifecycleService.stateChanges
        let paymentService = paymentService
        
        let appLifeCycleTask = Task { [weak self] in
            for await state in stateChanges {
                guard state == .active else { continue }
                await paymentService.refreshEntitlements()
                await self?.studySessionFactory.expireSessionIfNeeded()
                await self?.studySessionFactory.syncPendingOperations()
            }
        }
        
        appTasks.append(contentsOf: [connectivityTask, appLifeCycleTask])
    }
}

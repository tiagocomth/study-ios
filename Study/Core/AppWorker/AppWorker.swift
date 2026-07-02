//
//  AppWorker.swift
//  Study
//
//  Created by Caio Mandarino on 17/06/26.
//

import Foundation
import SwiftData
import Combine

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
    private var cancellables: Set<AnyCancellable>

    init(modelContainer: ModelContainer) {
        let session = UserSessionService.shared
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
        self.cancellables = []

        // Auto-logout whenever a request comes back 401. `logout()` is
        // `@MainActor`, so hop back to the main actor from the interceptor.
        AuthenticationInterceptor.shared.configure {
            Task { @MainActor in session.logout() }
        }

        self.appCoordinator = AppCoordinator()
        if !AppRuntime.isRunningTests {
            observeSessionChanges()
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

        cancellables.forEach { $0.cancel() }
    }
}

private extension AppWorker {
    private func observeSessionChanges() {
        userSessionService.$currentUser
            .map { $0?.id }
            .removeDuplicates()
            .sink { [weak self] userId in
                guard let self, userId != nil else { return }

                let task = Task { [weak self] in
                    await self?.studySessionFactory.restoreLocalState()
                    await self?.studySessionFactory.expireSessionIfNeeded()
                    await self?.studySessionFactory.syncPendingOperations()
                }

                self.appTasks.append(task)
            }
            .store(in: &cancellables)
    }
    
    private func configurePayments() {
        let paymentTask = Task {
            await paymentService.startTransactionListener { [paymentLogger, weak self] event in
                paymentLogger.info("App received payment event: \(event.logDescription)")
                
                guard let self else { return }
                
                switch event {
                case .purchased(_, let jwsString):
                    do {
                        let response: VerifyAppleTransactionResponse = try await self.apiClient.request(
                            PaymentEndpoint.verifyTransaction(signedTransactionInfo: jwsString)
                        )
                        
                        if response.success {
                            paymentLogger.info("Backend verified transaction successfully. User is premium: \(response.isPremium)")
                            await MainActor.run {
                                if let currentUser = self.userSessionService.currentUser {
                                    let updatedUser = User(
                                        id: currentUser.id,
                                        name: currentUser.name,
                                        photo: currentUser.photo,
                                        isPremium: response.isPremium,
                                        individualHoursTotal: currentUser.individualHoursTotal,
                                        groupHoursTotal: currentUser.groupHoursTotal
                                    )
                                    self.userSessionService.update(user: updatedUser)
                                }
                            }
                        } else {
                            paymentLogger.error("Backend returned success = false for verification.")
                        }
                    } catch {
                        paymentLogger.error("Failed to verify transaction with backend: \(error.localizedDescription)")
                    }
                default:
                    break
                }
            }

            await paymentService.refreshEntitlements()
        }
        
        appTasks.append(paymentTask)
    }

    private func configureStudySessionSync() {
        connectivityMonitorService.start()

        let initialSyncTask = Task { [weak self] in
            guard self?.userSessionService.isLoggedIn == true else { return }
            await self?.studySessionFactory.restoreLocalState()
            await self?.studySessionFactory.expireSessionIfNeeded()
            await self?.studySessionFactory.syncPendingOperations()
        }
        appTasks.append(initialSyncTask)

        let connectivityChanges = connectivityMonitorService.connectivityChanges
        let connectivityTask = Task { [weak self] in
            for await isConnected in connectivityChanges.dropFirst() {
                guard isConnected, self?.userSessionService.isLoggedIn == true else { continue }
                await self?.studySessionFactory.expireSessionIfNeeded()
                await self?.studySessionFactory.syncPendingOperations()
            }
        }
        
        let stateChanges = appLifecycleService.stateChanges
        let paymentService = paymentService
        
        let appLifeCycleTask = Task { [weak self] in
            for await state in stateChanges {
                guard state == .active, self?.userSessionService.isLoggedIn == true else { continue }
                await paymentService.refreshEntitlements()
                await self?.studySessionFactory.expireSessionIfNeeded()
                await self?.studySessionFactory.syncPendingOperations()
            }
        }
        
        appTasks.append(contentsOf: [connectivityTask, appLifeCycleTask])
    }
}

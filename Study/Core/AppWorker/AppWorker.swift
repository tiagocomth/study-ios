//
//  AppWorker.swift
//  Study
//
//  Created by Caio Mandarino on 17/06/26.
//

import Foundation

final class AppWorker {

    /// Single source of truth for the logged-in user, owned by the composition root.
    let userSessionService: UserSessionService

    /// Single configured network client. Injected downstream into the feature
    /// factories/services (instead of each one creating its own).
    let apiClient: APIClientProtocol
    let paymentService: PaymentProtocol

    private let appCoordinator: AppCoordinator
    private let paymentLogger: DomainLogging

    init() {
        let session = UserSessionService()
        self.userSessionService = session
        self.paymentLogger = PaymentLogger()
        self.paymentService = StoreKitPaymentService(logger: paymentLogger)

        // One client for the whole app; reads the current token from the session
        // on every request via the token provider closure.
        self.apiClient = APIClient(
            tokenProvider: TokenProvider { session.token }
        )

        // Auto-logout whenever a request comes back 401. `logout()` is
        // `@MainActor`, so hop back to the main actor from the interceptor.
        AuthenticationInterceptor.shared.configure {
            Task { @MainActor in session.logout() }
        }

        self.appCoordinator = AppCoordinator()
        configurePayments()
    }

    func makeAuthCoordinator() -> AuthCoordinator {
        return appCoordinator.makeAuthCoordinator(apiClient: apiClient, session: userSessionService)
    }

    func makeGroupCoordinator() -> GroupCoordinator {
        return appCoordinator.makeGroupCoordinator(apiClient: apiClient, session: userSessionService)
    }

}

private extension AppWorker {
    func configurePayments() {
        Task {
            await paymentService.startTransactionListener { [paymentLogger] event in
                paymentLogger.info("App received payment event: \(event.logDescription)")
                // TODO: implementar o uso do event
                
            }

            await paymentService.refreshEntitlements()
        }
    }
}

//TODO: Implementar o monitoramento de quando voltar para isActive a tela, dando um paymentService.refreshEntitlements()

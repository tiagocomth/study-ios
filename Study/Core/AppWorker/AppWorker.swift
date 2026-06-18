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

    private let appCoordinator: AppCoordinator

    init() {
        let session = UserSessionService()
        self.userSessionService = session

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

        self.appCoordinator = AppCoordinator(factory: .init())
    }

    func makeAuthCoordinator() -> AuthCoordinator {
        return appCoordinator.makeAuthCoordinator()
    }

}

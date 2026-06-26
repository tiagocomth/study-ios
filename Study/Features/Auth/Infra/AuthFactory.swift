//
//  AuthFactory.swift
//  Study
//

import SwiftUI

final class AuthFactory {

    weak var authCoordinator: AuthCoordinator?

    private let apiClient: APIClientProtocol
    private let session: UserSessionProtocol
    private let passwordResetSessionStore = PasswordResetSessionStore()


    init(apiClient: APIClientProtocol, session: UserSessionProtocol) {
        self.apiClient = apiClient
        self.session = session
    }

    func makeLoginView() -> some View {
        let viewModel = makeLoginVM()
        return LoginView(viewModel: viewModel)
    }

    func makeForgetPasswordView() -> some View {
        let viewModel = makeForgotPasswordVM()
        return ForgetPasswordView(viewModel: viewModel)
    }

    func makeCodeView() -> some View {
        let viewModel = makeCodeVM()
        return CodeView(viewModel: viewModel)
    }

    func makeNewPasswordView() -> some View {
        let viewModel = makeNewPasswordVM()
        return NewPasswordView(viewModel: viewModel)
    }

    func makeRegisterView() -> some View {
        let viewModel = makeRegisterVM()
        return RegisterView(viewModel: viewModel)
    }

    func makeEmailValidateView(email: Email) -> some View {
        let viewModel = makeEmailValidateVM(email: email)
        return EmailValidationView(viewModel: viewModel)
    }

}

// MARK: - Internal
extension AuthFactory {
    private func makeLoginVM() -> LoginViewModel {

        let viewModel = LoginViewModel(
            worker: LoginWorker(service: LoginService(apiClient: apiClient), session: session)
        )
        viewModel.coordinator = authCoordinator
        return viewModel
    }

    private func makeForgotPasswordVM() -> ForgetPasswordViewModel {
        let service = ForgetPasswordService(apiClient: apiClient)
        let viewModel = ForgetPasswordViewModel(worker: ForgetPasswordWorker(service: service))
        
        viewModel.coordinator = authCoordinator
        return viewModel
    }

    private func makeCodeVM() -> CodeViewModel {
        let service = CodeService(apiClient: apiClient)
        let worker = CodeWorker(service: service, sessionStore: passwordResetSessionStore)
        let viewModel = CodeViewModel(worker: worker)
        
        viewModel.coordinator = authCoordinator
        return viewModel
    }

    private func makeNewPasswordVM() -> NewPasswordViewModel {
        let service = NewPasswordService(apiClient: apiClient)
        let worker = NewPasswordWorker(service: service,sessionStore: passwordResetSessionStore)
        let viewModel = NewPasswordViewModel(worker: worker)
        
        viewModel.coordinator = authCoordinator
        return viewModel
    }

    private func makeRegisterVM() -> RegisterViewModel {
        let viewModel = RegisterViewModel(worker: RegisterWorker(service: RegisterService(apiClient: apiClient)))
        viewModel.coordinator = authCoordinator
        return viewModel
    }

    private func makeEmailValidateVM(email: Email) -> EmailValidationViewModel {
        EmailValidationViewModel(
            email: email,
            worker: EmailValidationWorker(
                service: EmailValidationService(apiClient: apiClient),
                session: session
            )
        )
    }
}

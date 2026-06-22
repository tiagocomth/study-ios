//
//  AuthFactory.swift
//  Study
//

import SwiftUI

final class AuthFactory {
    
    weak var authCoordinator: AuthCoordinator?
    private let apiClient: APIClientProtocol
    private let passwordResetSessionStore = PasswordResetSessionStore()

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
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
    
}

// MARK: - Internal
extension AuthFactory {
    private func makeLoginVM() -> LoginViewModel {
        let viewModel = LoginViewModel(worker: LoginWorker(service: LoginService()))
        
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
}

//
//  AuthFactory.swift
//  Study
//

import SwiftUI

final class AuthFactory {
    
    weak var authCoordinator: AuthCoordinator?
    private let apiClient: APIClientProtocol

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
        let viewModel = CodeViewModel(worker: CodeWorker(service: CodeService()))
        viewModel.coordinator = authCoordinator
        return viewModel
    }
    
    private func makeNewPasswordVM() -> NewPasswordViewModel {
        let viewModel = NewPasswordViewModel(worker: NewPasswordWorker(service: NewPasswordService()))
        viewModel.coordinator = authCoordinator
        return viewModel
    }
}

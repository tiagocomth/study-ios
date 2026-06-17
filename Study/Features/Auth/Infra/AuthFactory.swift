//
//  AuthFactory.swift
//  Study
//

import SwiftUI

final class AuthFactory {

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
        LoginViewModel(worker: LoginWorker(service: LoginService()))
    }
    
    private func makeForgotPasswordVM() -> ForgetPasswordViewModel {
        ForgetPasswordViewModel(worker: ForgetPasswordWorker(service: ForgetPasswordService()))
    }
    
    private func makeCodeVM() -> CodeViewModel {
        CodeViewModel(worker: CodeWorker(service: CodeService()))
    }
    
    private func makeNewPasswordVM() -> NewPasswordViewModel {
        NewPasswordViewModel(worker: NewPasswordWorker(service: NewPasswordService()))
    }
}

//
//  PremiumViewModel.swift
//  Study
//
//  Created by Breno Marques on 24/06/26.
//

import Foundation
import Combine

protocol PremiumCoordinatorProtocol: AnyObject {
    func dismissPremium()
}

final class PremiumViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPremium: Bool
    
    weak var coordinator: PremiumCoordinatorProtocol?
    private let worker: PremiumWorkerProtocol

    init(worker: PremiumWorkerProtocol) {
        self.worker = worker
        self.isPremium = worker.isPremium
    }
    
    @MainActor
    func purchasePremium() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await worker.purchasePremium()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func dismiss() {
        coordinator?.dismissPremium()
    }
}

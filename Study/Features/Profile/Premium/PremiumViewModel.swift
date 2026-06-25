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
    
    weak var coordinator: PremiumCoordinatorProtocol?
    private let worker: PremiumWorkerProtocol

    init(worker: PremiumWorkerProtocol) {
        self.worker = worker
    }

    func dismiss() {
        coordinator?.dismissPremium()
    }
}

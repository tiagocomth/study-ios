//
//  PremiumWorker.swift
//  Study
//
//  Created by Breno Marques on 24/06/26.
//

import Foundation

protocol PremiumWorkerProtocol {
}

final class PremiumWorker: PremiumWorkerProtocol {
    private let paymentService: PaymentProtocol
    private let userSession: UserSessionProtocol

    init(paymentService: PaymentProtocol, userSession: UserSessionProtocol) {
        self.paymentService = paymentService
        self.userSession = userSession
    }
}

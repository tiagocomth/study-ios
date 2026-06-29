//
//  PremiumWorker.swift
//  Study
//
//  Created by Breno Marques on 24/06/26.
//

import Foundation

protocol PremiumWorkerProtocol {
    var isPremium: Bool { get }
    func purchasePremium() async throws
}

final class PremiumWorker: PremiumWorkerProtocol {
    private let paymentService: PaymentProtocol
    private let userSession: UserSessionProtocol

    init(paymentService: PaymentProtocol, userSession: UserSessionProtocol) {
        self.paymentService = paymentService
        self.userSession = userSession
    }

    var isPremium: Bool {
        userSession.currentUser?.isPremium ?? false
    }

    func purchasePremium() async throws {
        guard let userIdString = userSession.currentUser?.id,
              let appAccountToken = UUID(uuidString: userIdString) else {
            throw NSError(domain: "PremiumWorker", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sessão inválida para compra."])
        }
        
        _ = try await paymentService.purchase(.premiumMonthly, appAccountToken: appAccountToken)
    }
}

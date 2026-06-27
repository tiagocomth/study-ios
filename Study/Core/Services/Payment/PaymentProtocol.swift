//
//  PaymentProtocol.swift
//  Study
//

import Foundation

typealias PaymentEventCallback = @Sendable (PaymentEvent) async -> Void

protocol PaymentProtocol: Sendable {

    func loadProducts() async throws(PaymentError) -> [PaymentProduct]
    func purchase(_ identifier: ProductIdentifier, appAccountToken: UUID) async throws(PaymentError) -> PaymentPurchaseResult
    func isPurchased(_ identifier: ProductIdentifier) async -> Bool
    func refreshEntitlements() async
    func startTransactionListener(callback: @escaping PaymentEventCallback) async
    func stopTransactionListener() async
}

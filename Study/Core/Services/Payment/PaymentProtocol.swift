//
//  PaymentProtocol.swift
//  Study
//

import Foundation

typealias PaymentEventCallback = @Sendable (PaymentEvent) async -> Void

protocol PaymentProtocol: Sendable {

    func loadProducts() async throws(PaymentError) -> [PaymentProduct]
    func purchase(_ identifier: ProductIdentifier) async throws(PaymentError) -> PaymentPurchaseResult
    func refreshEntitlements() async
    func startTransactionListener(callback: @escaping PaymentEventCallback) async
    func stopTransactionListener() async
}

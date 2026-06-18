//
//  StoreKitPaymentService.swift
//  Study
//

import Foundation
import StoreKit

final actor StoreKitPaymentService: PaymentProtocol {

    private var productsByIdentifier: [ProductIdentifier: Product]
    private var purchasedIdentifiers: Set<ProductIdentifier>
    private var transactionListenerTask: Task<Void, Never>?
    private var eventCallback: PaymentEventCallback?

    init() {
        self.productsByIdentifier = [:]
        self.purchasedIdentifiers = []
        self.transactionListenerTask = nil
        self.eventCallback = nil
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func loadProducts() async throws(PaymentError) -> [PaymentProduct] {
        let storeProducts: [Product]

        do {
            storeProducts = try await Product.products(for: ProductIdentifier.allCases.map(\.id))
        } catch {
            throw .productLoadingFailed(reason: error.localizedDescription)
        }

        for product in storeProducts {
            guard let identifier = ProductIdentifier(rawValue: product.id) else { continue }
            productsByIdentifier[identifier] = product
        }

        return ProductIdentifier.allCases.compactMap { identifier in
            productsByIdentifier[identifier].flatMap(PaymentProduct.init)
        }
    }

    func purchase(_ identifier: ProductIdentifier) async throws(PaymentError) -> PaymentPurchaseResult {
        do {
            let product = try await storeProduct(for: identifier)
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try verified(verificationResult, fallbackIdentifier: identifier)
                await apply(transaction: transaction)
                await transaction.finish()
                return .success(identifier)

            case .pending:
                await emit(.pending(identifier))
                return .pending(identifier)

            case .userCancelled:
                return .cancelled(identifier)

            @unknown default:
                let error = PaymentError.unknownPurchaseResult(identifier)
                await emit(.failed(identifier, error))
                throw error
            }
        } catch let error as PaymentError {
            await emit(.failed(identifier, error))
            throw error
        } catch {
            let paymentError = PaymentError.purchaseFailed(
                identifier,
                reason: error.localizedDescription
            )
            await emit(.failed(identifier, paymentError))
            throw paymentError
        }
    }

    // MARK: Entitlements

    func refreshEntitlements() async {
        await syncCurrentEntitlements()
    }

    // MARK: Transaction Listener

    func startTransactionListener(callback: @escaping PaymentEventCallback) async {
        eventCallback = callback

        guard transactionListenerTask == nil else {
            return
        }

        transactionListenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard !Task.isCancelled else { break }
                await self?.handle(transactionResult: result)
            }
        }
    }

    func stopTransactionListener() async {
        transactionListenerTask?.cancel()
        transactionListenerTask = nil
        eventCallback = nil
    }
}

// MARK: - Private Helpers

private extension StoreKitPaymentService {
    private func storeProduct(for identifier: ProductIdentifier) async throws(PaymentError) -> Product {
        if let cachedProduct = productsByIdentifier[identifier] {
            return cachedProduct
        }

        let id = identifier.id
        let products: [Product]

        do {
            products = try await Product.products(for: [id])
        } catch {
            throw .productLoadingFailed(reason: error.localizedDescription)
        }

        guard let product = products.first(where: { $0.id == id }) else {
            throw PaymentError.productNotFound(identifier)
        }

        productsByIdentifier[identifier] = product
        return product
    }

    private func handle(transactionResult result: VerificationResult<Transaction>) async {
        do {
            let transaction = try verified(result, fallbackIdentifier: nil)
            await apply(transaction: transaction)
            await transaction.finish()
        } catch {
            await emit(.failed(nil, error))
        }
    }

    private func syncCurrentEntitlements() async {
        var activeIdentifiers = Set<ProductIdentifier>()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try verified(result, fallbackIdentifier: nil)

                guard let identifier = ProductIdentifier(rawValue: transaction.productID) else {
                    continue
                }

                guard isTransactionActive(transaction) else {
                    await emitInactiveEvent(for: transaction, identifier: identifier)
                    continue
                }

                activeIdentifiers.insert(identifier)

                if !purchasedIdentifiers.contains(identifier) {
                    await emit(.purchased(identifier))
                }
            } catch {
                await emit(.failed(nil, error))
            }
        }

        let removedIdentifiers = purchasedIdentifiers.subtracting(activeIdentifiers)
        purchasedIdentifiers = activeIdentifiers

        for identifier in removedIdentifiers {
            await emitInactiveEventForLatestTransaction(identifier)
        }
    }

    private func apply(transaction: Transaction) async {
        guard let identifier = ProductIdentifier(rawValue: transaction.productID) else {
            await emit(.failed(nil, .unknownProduct(transaction.productID)))
            return
        }

        guard isTransactionActive(transaction) else {
            purchasedIdentifiers.remove(identifier)
            await emitInactiveEvent(for: transaction, identifier: identifier)
            return
        }

        purchasedIdentifiers.insert(identifier)
        await emit(.purchased(identifier))
    }

    private func verified<T>(
        _ result: VerificationResult<T>,
        fallbackIdentifier: ProductIdentifier?
    ) throws(PaymentError) -> T {
        switch result {
        case .verified(let signedType):
            return signedType

        case .unverified(let signedType, let verificationError):
            let productIdentifier: ProductIdentifier?

            if let transaction = signedType as? Transaction {
                productIdentifier = ProductIdentifier(rawValue: transaction.productID) ?? fallbackIdentifier
            } else {
                productIdentifier = fallbackIdentifier
            }

            throw PaymentError.failedVerification(
                productIdentifier: productIdentifier,
                reason: verificationError.localizedDescription
            )
        }
    }

    private func isTransactionActive(_ transaction: Transaction) -> Bool {
        guard transaction.revocationDate == nil else {
            return false
        }

        if let expirationDate = transaction.expirationDate {
            return expirationDate > Date()
        }

        return true
    }

    private func emitInactiveEvent(for transaction: Transaction, identifier: ProductIdentifier) async {
        if transaction.revocationDate != nil {
            await emit(.revoked(identifier))
            return
        }

        if let expirationDate = transaction.expirationDate, expirationDate <= Date() {
            await emit(.expired(identifier))
        }
    }

    private func emitInactiveEventForLatestTransaction(_ identifier: ProductIdentifier) async {
        guard let result = await Transaction.latest(for: identifier.id),
              let transaction = try? verified(result, fallbackIdentifier: identifier) else {
            return
        }

        await emitInactiveEvent(for: transaction, identifier: identifier)
    }

    private func emit(_ event: PaymentEvent) async {
        guard let eventCallback else { return }
        await eventCallback(event)
    }
}

private extension PaymentProduct {
    
    nonisolated init?(_ product: Product) {
        guard let identifier = ProductIdentifier(rawValue: product.id) else {
            return nil
        }

        self.init(
            identifier: identifier,
            name: product.displayName,
            description: product.description,
            price: product.displayPrice
        )
    }
}

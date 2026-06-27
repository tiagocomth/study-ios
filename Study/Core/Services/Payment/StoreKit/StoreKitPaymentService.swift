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
    private let logger: DomainLogging

    init(logger: DomainLogging = PaymentLogger()) {
        self.productsByIdentifier = [:]
        self.purchasedIdentifiers = []
        self.transactionListenerTask = nil
        self.eventCallback = nil
        self.logger = logger
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func loadProducts() async throws(PaymentError) -> [PaymentProduct] {
        logger.info("Loading products from StoreKit")

        let storeProducts: [Product]

        do {
            storeProducts = try await Product.products(for: ProductIdentifier.allCases.map(\.id))
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
            throw .productLoadingFailed(reason: error.localizedDescription)
        }

        for product in storeProducts {
            guard let identifier = ProductIdentifier(rawValue: product.id) else { continue }
            productsByIdentifier[identifier] = product
        }

        let paymentProducts = ProductIdentifier.allCases.compactMap { identifier in
            productsByIdentifier[identifier].flatMap(PaymentProduct.init)
        }

        logger.info("Loaded \(paymentProducts.count) products")
        return paymentProducts
    }

    func purchase(_ identifier: ProductIdentifier, appAccountToken: UUID) async throws(PaymentError) -> PaymentPurchaseResult {
        logger.info("Starting purchase for \(identifier.id)")

        do {
            let product = try await storeProduct(for: identifier)
            let result = try await product.purchase(options: [.appAccountToken(appAccountToken)])

            switch result {
            case .success(let verificationResult):
                let transaction = try verified(verificationResult, fallbackIdentifier: identifier)
                await apply(transaction: transaction, identifier: identifier)
                await transaction.finish()
                logger.info("Purchase finished successfully for \(identifier.id)")
                return .success(identifier)

            case .pending:
                await emit(.pending(identifier))
                logger.info("Purchase pending for \(identifier.id)")
                return .pending(identifier)

            case .userCancelled:
                logger.info("Purchase cancelled by user for \(identifier.id)")
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

    func refreshEntitlements() async {
        logger.info("Refreshing current entitlements")
        await syncCurrentEntitlements()
    }

    func isPurchased(_ identifier: ProductIdentifier) async -> Bool {
        return purchasedIdentifiers.contains(identifier)
    }

    func startTransactionListener(callback: @escaping PaymentEventCallback) async {
        eventCallback = callback

        guard transactionListenerTask == nil else {
            logger.debug("Transaction listener already running")
            return
        }

        logger.info("Starting transaction listener")
        transactionListenerTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard !Task.isCancelled else { break }
                await self?.handle(transactionResult: result)
            }
        }
    }

    func stopTransactionListener() async {
        logger.info("Stopping transaction listener")
        transactionListenerTask?.cancel()
        transactionListenerTask = nil
        eventCallback = nil
    }
}

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
            logger.error("Failed to load product \(id): \(error.localizedDescription)")
            throw .productLoadingFailed(reason: error.localizedDescription)
        }

        guard let product = products.first(where: { $0.id == id }) else {
            logger.error("Product not found: \(id)")
            throw PaymentError.productNotFound(identifier)
        }

        productsByIdentifier[identifier] = product
        return product
    }

    private func handle(transactionResult result: VerificationResult<Transaction>) async {
        do {
            let transaction = try verified(result, fallbackIdentifier: nil)
            let identifier = try productIdentifier(for: transaction)

            logger.debug("Received transaction update for \(identifier.id)")
            await apply(transaction: transaction, identifier: identifier)
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
                let identifier = try productIdentifier(for: transaction)

                guard isTransactionActive(transaction) else {
                    await emitInactiveEvent(for: transaction, identifier: identifier)
                    continue
                }

                activeIdentifiers.insert(identifier)

                if !purchasedIdentifiers.contains(identifier) {
                    await emitPurchased(for: transaction, identifier: identifier)
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

        logger.info("Active entitlements refreshed: \(activeIdentifiers.map(\.id).joined(separator: ", "))")
    }

    private func apply(transaction: Transaction, identifier: ProductIdentifier) async {
        guard isTransactionActive(transaction) else {
            purchasedIdentifiers.remove(identifier)
            await emitInactiveEvent(for: transaction, identifier: identifier)
            return
        }

        purchasedIdentifiers.insert(identifier)
        await emitPurchased(for: transaction, identifier: identifier)
    }

    private func verified(
        _ result: VerificationResult<Transaction>,
        fallbackIdentifier: ProductIdentifier?
    ) throws(PaymentError) -> Transaction {
        switch result {
        case .verified(let transaction):
            guard ProductIdentifier(rawValue: transaction.productID) != nil || fallbackIdentifier != nil else {
                throw .unknownProduct(transaction.productID)
            }

            return transaction

        case .unverified(let transaction, let verificationError):
            let productIdentifier = ProductIdentifier(rawValue: transaction.productID) ?? fallbackIdentifier

            throw .failedVerification(
                productIdentifier: productIdentifier,
                reason: verificationError.localizedDescription
            )
        }
    }

    private func productIdentifier(for transaction: Transaction) throws(PaymentError) -> ProductIdentifier {
        guard let identifier = ProductIdentifier(rawValue: transaction.productID) else {
            throw .unknownProduct(transaction.productID)
        }

        return identifier
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
            await emit(
                .revoked(
                    product: identifier,
                    transactionJSON: transaction.jsonRepresentation
                )
            )
            return
        }

        if let expirationDate = transaction.expirationDate, expirationDate <= Date() {
            await emit(
                .expired(
                    product: identifier,
                    transactionJSON: transaction.jsonRepresentation
                )
            )
        }
    }

    private func emitInactiveEventForLatestTransaction(_ identifier: ProductIdentifier) async {
        guard let result = await Transaction.latest(for: identifier.id),
              let transaction = try? verified(
                result,
                fallbackIdentifier: identifier
              ) else {
            return
        }

        await emitInactiveEvent(for: transaction, identifier: identifier)
    }

    private func emit(_ event: PaymentEvent) async {
        await logger.info("Payment event: \(event.logDescription)")
        guard let eventCallback else { return }
        await eventCallback(event)
    }

    private func emitPurchased(for transaction: Transaction, identifier: ProductIdentifier) async {
        await emit(
            .purchased(
                product: identifier,
                transactionJSON: transaction.jsonRepresentation
            )
        )
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

//
//  PaymentResult.swift
//  Study
//

import Foundation

enum PaymentPurchaseResult: Sendable, Equatable {
    case success(ProductIdentifier)
    case pending(ProductIdentifier)
    case cancelled(ProductIdentifier)
}

enum PaymentEvent: Sendable, Equatable {
    case purchased(ProductIdentifier)
    case revoked(ProductIdentifier)
    case expired(ProductIdentifier)
    case pending(ProductIdentifier)
    case failed(ProductIdentifier?, PaymentError)
}

enum PaymentError: Error, Sendable, Equatable, LocalizedError {
    case productLoadingFailed(reason: String)
    case productNotFound(ProductIdentifier)
    case failedVerification(productIdentifier: ProductIdentifier?, reason: String)
    case unknownProduct(String)
    case unknownPurchaseResult(ProductIdentifier)
    case purchaseFailed(ProductIdentifier, reason: String)

    var errorDescription: String? {
        switch self {
        case .productLoadingFailed(let reason):
            return "Product loading failed: \(reason)."

        case .productNotFound(let identifier):
            return "Product not found: \(identifier.id)."

        case .failedVerification(let productIdentifier, let reason):
            if let productIdentifier {
                return "Transaction verification failed for \(productIdentifier.id): \(reason)."
            }
            return "Transaction verification failed: \(reason)."

        case .unknownProduct(let productID):
            return "Unknown product identifier received from StoreKit: \(productID)."

        case .unknownPurchaseResult(let identifier):
            return "Unknown purchase result for product: \(identifier.id)."

        case .purchaseFailed(let identifier, let reason):
            return "Purchase failed for \(identifier.id): \(reason)."
        }
    }
}

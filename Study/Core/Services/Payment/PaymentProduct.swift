//
//  PaymentProduct.swift
//  Study
//

import Foundation

nonisolated enum ProductIdentifier: String, CaseIterable {
    case premiumMonthly = "com.yourcompany.yourapp.premium.monthly"

    var id: String {
        rawValue
    }
}

nonisolated struct PaymentProduct: Sendable, Equatable, Identifiable {
    let identifier: ProductIdentifier
    let name: String
    let description: String
    let price: String

    var id: String {
        identifier.id
    }
}

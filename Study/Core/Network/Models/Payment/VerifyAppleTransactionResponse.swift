//
//  VerifyAppleTransactionResponse.swift
//  Study
//

import Foundation

nonisolated struct VerifyAppleTransactionResponse: Decodable, Sendable {
    let success: Bool
    let isPremium: Bool
    
    enum CodingKeys: String, CodingKey {
        case success
        case isPremium = "is_premium"
    }
}

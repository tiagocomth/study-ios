//
//  PaymentEndpoint.swift
//  Study
//

import Foundation

enum PaymentEndpoint {
    case verifyTransaction(signedTransactionInfo: String)
}

extension PaymentEndpoint: Endpoint {
    struct VerifyTransactionRequest: Encodable {
        let signedTransactionInfo: String
    }

    var path: String {
        switch self {
        case .verifyTransaction:
            return "/webhooks/apple-pay/verify-transaction"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .verifyTransaction:
            return .post
        }
    }

    var task: HTTPTask {
        switch self {
        case .verifyTransaction(let signedTransactionInfo):
            let body = VerifyTransactionRequest(signedTransactionInfo: signedTransactionInfo)
            return .requestJSONBody(body)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}

//
//  APIConstants.swift
//  Study
//

import Foundation

enum APIConstants {
    /// Host base da API (sem scheme e sem path — o `RequestBuilder` adiciona `https://`).
    /// Lido de `API_BASE_URL`, injetado no Info.plist a partir do `Config.xcconfig` (não versionado).
    static let host: String = {
        guard
            let host = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            !host.isEmpty
        else {
            assertionFailure("API_BASE_URL ausente — confira o Config.xcconfig e o INFOPLIST_KEY_API_BASE_URL.")
            return ""
        }
        return host
    }()
}

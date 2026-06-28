//
//  RequestBuilder.swift
//  Study
//
//  Created by Thiago de Jesus on 08/03/26.
//

import Foundation

/// HTTP request builder for endpoints described by `Endpoint`.
///
/// This structure encapsulates the logic to transform an endpoint
/// (method, path, parameters, body, and headers) into a `URLRequest`
/// ready to be sent via `URLSession`.
struct RequestBuilder {
    /// Builds a `URLRequest` from an `Endpoint`.
    ///
    /// - Parameters:
    ///   - from: The endpoint that describes baseURL, path, method, task (parameters/body), and headers.
    ///   - token: Optional bearer token. When non-empty, an `Authorization: Bearer <token>`
    ///     header is added. Endpoint-specific `headers` are applied afterwards, so they can
    ///     still override it when needed.
    /// - Returns: A configured `URLRequest` or `nil` if the final URL cannot be constructed or body serialization fails.
    ///
    /// Behavior:
    /// - Uses the `https` scheme by default.
    /// - Sets a `timeoutInterval` of 30s.
    /// - Sets `Accept` to `application/json`.
    /// - Sets `Content-Type` to `application/json` only for `requestJSONBody`.
    /// - `requestPlain`: sets `Content-Length` to `0`.
    /// - `requestURLParameters`: converts the dictionary into `queryItems`.
    /// - `requestJSONBody`: encodes the body using `JSONEncoder`.
    /// - Injects the bearer `token` when provided.
    /// - Applies additional headers defined in `from.headers`.
    static func build(_ from: Endpoint, token: String? = nil) -> URLRequest? {

        // Build URL from scheme, host and path provided by the endpoint
        var components = URLComponents()
        components.scheme = "https"
        components.host = from.baseURL
        components.path = from.path

        // Ensure the URL is valid; otherwise, fail gracefully
        guard let url = components.url else { return nil }

        // Initial URLRequest configuration (HTTP method and timeout)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = from.method.rawValue
        urlRequest.timeoutInterval = 30


        // Configure task (parameters, body, or plain request)
        switch from.task {
        case .requestPlain:
            // Request without body or parameters; set Content-Length = 0
            urlRequest.setValue("0", forHTTPHeaderField: "Content-Length")
        case .requestURLParameters(let parameters):
            // Convert parameters to query string
            components.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            urlRequest.url = components.url
        case .requestJSONBody(let body):
            // Serialize body as JSON
            let encoder = JSONEncoder()
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                return nil
            }
        }

        // `Content-Type` should only describe an actual request body payload.
        if case .requestJSONBody = from.task {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        // Authorization (only when a non-empty token is available)
        if let token, !token.isEmpty {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Additional headers provided by the endpoint
        from.headers?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        return urlRequest
    }
}

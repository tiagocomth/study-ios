//
//  APIClient.swift
//  Study
//
//  Created by Thiago de Jesus on 08/03/26.
//

import Foundation

protocol APIClientProtocol {
    /// Performs a request against `endpoint`.
    /// - Parameter token: Bearer token for this specific call. When non-nil it
    ///   overrides the client's `tokenProvider` (used e.g. to send a short-lived
    ///   reset/OTP token). When nil, the client falls back to the `tokenProvider`.
    func request<T: Decodable>(_ endpoint: Endpoint, token: String?) async throws(NetworkError) -> T
}

extension APIClientProtocol {
    /// Convenience overload for calls that rely on the client's `tokenProvider`.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws(NetworkError) -> T {
        try await request(endpoint, token: nil)
    }
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let tokenProvider: TokenProviding?
    private let interceptor: AuthenticationInterceptorProtocol?
    private let logger: NetworkLogging?

    /// - Parameters:
    ///   - session: The `URLSession` used to perform requests.
    ///   - tokenProvider: Supplies the bearer token injected into every request.
    ///     Pass `nil` for unauthenticated clients.
    ///   - interceptor: Notified when a request fails with `401`, so the app can
    ///     react (e.g. log out). Defaults to the shared interceptor.
    ///   - logger: Logs requests and their outcomes. Pass `nil` to silence logging
    ///     (e.g. in tests). Defaults to an `os.Logger`-backed `NetworkLogger`.
    init(
        session: URLSession = .shared,
        tokenProvider: TokenProviding? = nil,
        interceptor: AuthenticationInterceptorProtocol? = AuthenticationInterceptor.shared,
        logger: NetworkLogging? = NetworkLogger()
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
        self.interceptor = interceptor
        self.logger = logger
    }

    func request<T>(_ endpoint: any Endpoint, token: String? = nil) async throws(NetworkError) -> T where T : Decodable {
        // A per-call token (e.g. a reset/OTP token) takes precedence over the
        // client's default token provider.
        let resolvedToken = token ?? tokenProvider?.token
        guard let request = RequestBuilder.build(endpoint, token: resolvedToken) else {
            throw NetworkError.requestBuildFailed(message: "Failed to create request from endpoint.")
        }
        return try await perform(request)
    }
}


extension APIClient {


    private func perform<T: Decodable>(_ request: URLRequest) async throws(NetworkError) -> T {

        logger?.logRequest(request)

        let data: Data
        let response: URLResponse
        do{
            (data, response) = try await session.data(for: request)
        } catch(let error) {
            logger?.logFailure(error, for: request)
            throw NetworkError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            let error = NetworkError.noResponse(message: "Invalid response from server.")
            logger?.logFailure(error, for: request)
            throw error
        }

        logger?.logResponse(httpResponse, data: data, for: request)

        try checkStatus(status: httpResponse.statusCode, data: data)

        // Responses with no body (e.g. 204 No Content or a DELETE): only an
        // `EmptyResponse` is valid here — decoding anything else would fail.
        if data.isEmpty {
            if let empty = EmptyResponse() as? T {
                return empty
            }
            throw NetworkError.emptyData(message: "Expected a response body but received none.")
        }

        do{
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // Surfaces the underlying `DecodingError` (missing key, type mismatch…)
            // so the exact field that broke shows up in logs and error messages.
            logger?.logFailure(error, for: request)
            throw NetworkError.decodingFailed(message: "Failed to decode data to model: \(error)")
        }

    }

    private func checkStatus(status: Int, data: Data) throws(NetworkError) {
        // Quando a API devolve um corpo de erro (`{ message, ... }`), preferimos
        // essa mensagem do servidor à mensagem genérica — assim a UI mostra o
        // motivo real (ex.: "Você já é membro deste grupo.").
        let serverMessage = Self.serverMessage(from: data)

        switch status {
        case 200...299:
            return
        case 401:
            interceptor?.handleUnauthorized()
            throw NetworkError.unauthorized(
                message: serverMessage ?? "Unauthorized request. Authentication required."
            )
        case 403:
            throw NetworkError.forbidden(
                message: serverMessage ?? "Forbidden request. You don't have permission to access this resource."
            )
        case 404:
            throw NetworkError.notFound(
                message: serverMessage ?? "Requested resource was not found."
            )
        default:
            throw NetworkError.invalidStatusCode(
                codeStatus: status,
                message: serverMessage ?? "Unexpected status code: \(status)"
            )
        }
    }

    /// Extrai o campo `message` de um corpo de erro padrão da API. `nil` quando o
    /// corpo é vazio ou não tem essa forma.
    private static func serverMessage(from data: Data) -> String? {
        struct ServerErrorBody: Decodable { let message: String? }
        guard !data.isEmpty,
              let body = try? JSONDecoder().decode(ServerErrorBody.self, from: data),
              let message = body.message,
              !message.isEmpty
        else { return nil }
        return message
    }
}

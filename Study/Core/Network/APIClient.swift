//
//  APIClient.swift
//  Study
//
//  Created by Thiago de Jesus on 08/03/26.
//

import Foundation

protocol APIClientProtocol {

    init(session: URLSession)

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request<T: Decodable>(_ path: String) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T>(_ endpoint: any Endpoint) async throws -> T where T : Decodable {

        guard let request = RequestBuilder.build(endpoint) else {
            throw NetworkError.requestBuildFailed(message: "Failed to create request from endpoint.")
        }

        return try await perform(request)

    }

    func request<T>(_ path: String) async throws -> T where T : Decodable {

        guard let url = URL(string: path) else {
            throw NetworkError.invalidURL(message: "Invalid URL.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue

        return try await perform(request)


    }

}


extension APIClient {


    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {

        let data: Data
        let response: URLResponse
        do{
            (data, response) = try await session.data(for: request)
        } catch(let error) {
            throw NetworkError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noResponse(message: "Invalid response from server.")
        }

        try checkStatus(status: httpResponse.statusCode)

        do{
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(message: "Failed to decode data to model.")
        }

    }

    func checkStatus(status: Int) throws {
        switch status {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized(
                message: "Unauthorized request. Authentication required."
            )
        case 403:
            throw NetworkError.forbidden(
                message: "Forbidden request. You don't have permission to access this resource."
            )
        case 404:
            throw NetworkError.notFound(
                message: "Requested resource was not found."
            )
        default:
            throw NetworkError.invalidStatusCode(
                codeStatus: status,
                message: "Unexpected status code: \(status)"
            )
        }
    }
}

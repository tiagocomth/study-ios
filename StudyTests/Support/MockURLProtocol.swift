//
//  MockURLProtocol.swift
//  StudyTests
//

import Foundation

/// A `URLProtocol` that intercepts every request and returns a canned response,
/// so `APIClient` can be exercised without hitting the network.
///
/// State is `static` because `URLSession` instantiates the protocol itself, so
/// there is no per-request instance to configure. The `APIClient` suite runs
/// `.serialized` to avoid races on this shared state.
final class MockURLProtocol: URLProtocol {

    nonisolated(unsafe) static var statusCode = 200
    nonisolated(unsafe) static var responseData = Data()
    /// The last request that reached the network, for asserting on headers/body.
    nonisolated(unsafe) static var lastRequest: URLRequest?

    static func reset() {
        statusCode = 200
        responseData = Data()
        lastRequest = nil
    }

    /// A `URLSession` wired to use this mock protocol.
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        MockURLProtocol.lastRequest = request

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: MockURLProtocol.statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: MockURLProtocol.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

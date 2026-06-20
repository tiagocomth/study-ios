//
//  TestDoubles.swift
//  StudyTests
//

import Foundation
@testable import Study

/// A simple model decoded/encoded in the network tests.
struct TestUser: Codable, Equatable {
    let id: String
    let name: String
}

/// A configurable `Endpoint` for the tests. Defaults to a plain GET so each test
/// only overrides what it cares about.
struct TestEndpoint: Endpoint {
    var baseURL: String = "example.com"
    var path: String = "/test"
    var method: HTTPMethod = .get
    var task: HTTPTask = .requestPlain
    var headers: Headers? = nil
}

/// Records whether the client reported a 401 to the interceptor.
final class InterceptorSpy: AuthenticationInterceptorProtocol, @unchecked Sendable {
    private(set) var handleUnauthorizedCallCount = 0

    func handleUnauthorized() {
        handleUnauthorizedCallCount += 1
    }
}

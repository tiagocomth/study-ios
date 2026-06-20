//
//  APIClientTests.swift
//  StudyTests
//

import Testing
import Foundation
@testable import Study

@MainActor
@Suite("APIClient", .serialized)
struct APIClientTests {

    init() {
        MockURLProtocol.reset()
    }

    private func makeClient(
        token: String? = "token-123",
        interceptor: AuthenticationInterceptorProtocol? = nil
    ) -> APIClient {
        APIClient(
            session: MockURLProtocol.makeSession(),
            tokenProvider: TokenProvider { token },
            interceptor: interceptor,
            logger: nil
        )
    }

    @Test("decodes a 200 JSON body into the model")
    func decodesSuccess() async throws {
        MockURLProtocol.statusCode = 200
        MockURLProtocol.responseData = Data(#"{"id":"1","name":"Tiago"}"#.utf8)

        let user: TestUser = try await makeClient().request(TestEndpoint())

        #expect(user == TestUser(id: "1", name: "Tiago"))
    }

    @Test("injects the bearer token into the Authorization header")
    func injectsBearerToken() async throws {
        MockURLProtocol.statusCode = 200
        MockURLProtocol.responseData = Data(#"{"id":"1","name":"x"}"#.utf8)

        let _: TestUser = try await makeClient(token: "abc-987").request(TestEndpoint())

        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer abc-987")
    }

    @Test("omits Authorization when there is no token")
    func omitsAuthorizationWithoutToken() async throws {
        MockURLProtocol.statusCode = 200
        MockURLProtocol.responseData = Data(#"{"id":"1","name":"x"}"#.utf8)

        let _: TestUser = try await makeClient(token: nil).request(TestEndpoint())

        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("a 401 notifies the interceptor and throws")
    func unauthorizedNotifiesInterceptor() async {
        MockURLProtocol.statusCode = 401
        let spy = InterceptorSpy()

        await #expect(throws: NetworkError.self) {
            let _: TestUser = try await self.makeClient(interceptor: spy).request(TestEndpoint())
        }
        #expect(spy.handleUnauthorizedCallCount == 1)
    }

    @Test("an empty 204 body decodes into EmptyResponse")
    func emptyBodyDecodesToEmptyResponse() async throws {
        MockURLProtocol.statusCode = 204
        MockURLProtocol.responseData = Data()

        // Must not throw: EmptyResponse is the valid model for an empty body.
        let _: EmptyResponse = try await makeClient().request(TestEndpoint())
    }

    @Test("an empty body for a decodable model throws")
    func emptyBodyForModelThrows() async {
        MockURLProtocol.statusCode = 200
        MockURLProtocol.responseData = Data()

        await #expect(throws: NetworkError.self) {
            let _: TestUser = try await self.makeClient().request(TestEndpoint())
        }
    }

    @Test("invalid JSON throws")
    func invalidJSONThrows() async {
        MockURLProtocol.statusCode = 200
        MockURLProtocol.responseData = Data("not json".utf8)

        await #expect(throws: NetworkError.self) {
            let _: TestUser = try await self.makeClient().request(TestEndpoint())
        }
    }

    @Test("maps common error status codes", arguments: [403, 404, 500])
    func mapsErrorStatus(_ status: Int) async {
        MockURLProtocol.statusCode = status
        MockURLProtocol.responseData = Data()

        await #expect(throws: NetworkError.self) {
            let _: TestUser = try await self.makeClient().request(TestEndpoint())
        }
    }
}

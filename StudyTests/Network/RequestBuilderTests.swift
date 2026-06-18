//
//  RequestBuilderTests.swift
//  StudyTests
//

import Testing
import Foundation
@testable import Study

@Suite("RequestBuilder")
struct RequestBuilderTests {

    @Test("builds an https URL from baseURL and path")
    func buildsURL() throws {
        let request = try #require(
            RequestBuilder.build(TestEndpoint(baseURL: "api.study.com", path: "/users"))
        )
        #expect(request.url?.absoluteString == "https://api.study.com/users")
        #expect(request.httpMethod == "GET")
        #expect(request.timeoutInterval == 30)
    }

    @Test("sets JSON content-type and accept headers")
    func setsDefaultHeaders() throws {
        let request = try #require(RequestBuilder.build(TestEndpoint()))
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test("injects the bearer token when provided")
    func injectsToken() throws {
        let request = try #require(RequestBuilder.build(TestEndpoint(), token: "xyz"))
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer xyz")
    }

    @Test("does not inject Authorization for a nil or empty token")
    func noTokenNoHeader() throws {
        let nilToken = try #require(RequestBuilder.build(TestEndpoint(), token: nil))
        let emptyToken = try #require(RequestBuilder.build(TestEndpoint(), token: ""))
        #expect(nilToken.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(emptyToken.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("encodes a JSON body and keeps the method")
    func encodesJSONBody() throws {
        let endpoint = TestEndpoint(
            method: .post,
            task: .requestJSONBody(TestUser(id: "1", name: "Tiago"))
        )
        let request = try #require(RequestBuilder.build(endpoint))
        let body = try #require(request.httpBody)

        #expect(request.httpMethod == "POST")
        #expect(try JSONDecoder().decode(TestUser.self, from: body) == TestUser(id: "1", name: "Tiago"))
    }

    @Test("encodes URL query parameters")
    func encodesQueryParameters() throws {
        let endpoint = TestEndpoint(task: .requestURLParameters(["page": 2]))
        let request = try #require(RequestBuilder.build(endpoint))
        #expect(request.url?.query?.contains("page=2") == true)
    }

    @Test("applies endpoint-specific headers")
    func appliesCustomHeaders() throws {
        let endpoint = TestEndpoint(headers: ["X-Custom": "value"])
        let request = try #require(RequestBuilder.build(endpoint))
        #expect(request.value(forHTTPHeaderField: "X-Custom") == "value")
    }
}

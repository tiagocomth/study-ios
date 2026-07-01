//
//  AuthResponseDTOTests.swift
//  StudyTests
//

import Foundation
import Testing
@testable import Study

@Suite("AuthResponseDTO", .serialized)
struct AuthResponseDTOTests {

    @Test("decodes login payload even when is_premium is omitted")
    func decodesWithoutPremiumFlag() throws {
        let data = Data(#"{"accessToken":"token-123","user":{"id":"1","email":"tiago@example.com"}}"#.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(AuthResponseDTO.self, from: data)

        #expect(response.accessToken == "token-123")
        #expect(response.user.id == "1")
        #expect(response.user.email == "tiago@example.com")
        #expect(response.user.isPremium == false)
    }

    @Test("decodes login payload when is_premium is present")
    func decodesWithPremiumFlag() throws {
        let data = Data(#"{"accessToken":"token-123","user":{"id":"1","email":"tiago@example.com","is_premium":true}}"#.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(AuthResponseDTO.self, from: data)

        #expect(response.user.isPremium == true)
    }
}

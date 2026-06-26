//
//  EmptyResponse.swift
//  Study
//
//  Created by Thiago de Jesus on 18/06/26.
//

import Foundation

/// Placeholder model for endpoints that return no body (e.g. `204 No Content`
/// or a `DELETE`). Decode into this type so a successful empty response does
/// not fail with `NetworkError.decodingFailed`:
/// ```swift
/// let _: EmptyResponse = try await client.request(endpoint)
/// ```
nonisolated struct EmptyResponse: Decodable, Sendable {}

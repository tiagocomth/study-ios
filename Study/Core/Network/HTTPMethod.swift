//
//  HTTPMethod.swift
//  Study
//
//  Created by Thiago de Jesus on 08/03/26.
//

/// Defines the HTTP methods supported by the network layer.

import Foundation

/// An HTTP method used when performing network requests.
/// Values map directly to their standard string representations.
enum HTTPMethod: String, Codable {
    /// The GET method.
    case get = "GET"
    /// The POST method.
    case post = "POST"
    /// The PUT method.
    case put = "PUT"
    /// The DELETE method.
    case delete = "DELETE"
    /// The PATCH method.
    case patch = "PATCH"
}

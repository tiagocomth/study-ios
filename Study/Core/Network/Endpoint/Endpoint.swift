//
//  Endpoint.swift
//  Study
//
//  Created by Thiago de Jesus on 08/03/26.
//

import Foundation

/// A dictionary of HTTP header fields to include in a request.
/// Keys and values are raw header strings (for example, "Authorization" or "Content-Type").
typealias Headers = [String: String]

/// Describes an HTTP endpoint.
/// Conforming types define the base URL, path, HTTP method, task and optional headers.
protocol Endpoint {
    /// The base URL of the service (e.g., "https://api.example.com").
    var baseURL: String { get }
    /// The path component to append to the base URL (e.g., "/users").
    var path : String { get }
    /// The HTTP method to use when performing the request.
    var method: HTTPMethod { get }
    /// The type of task describing how to build the request (e.g., plain or with parameters).
    var task: HTTPTask { get }
    /// Optional additional HTTP headers specific to this endpoint.
    var headers: Headers? { get }
}

extension Endpoint {
    var baseURL: String { "api.example.com" } // TODO: Replace with the real API host when the endpoint is available.
}

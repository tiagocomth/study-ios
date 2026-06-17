//
//  HTTPTask.swift
//  Study
//
//  Created by Thiago de Jesus on 08/03/26.

/// Defines the HTTP task types supported by the network layer.
/// A task describes how to build the request body or parameters for an endpoint.

import Foundation

/// A dictionary of request parameters encoded into the URL query or body, depending on the task.
typealias Parameters = [String: Any]

enum HTTPTask {
    /// A plain request without parameters or body.
    case requestPlain
    /// A request that encodes the provided parameters into the URL query string.
    /// - Parameter parameters: Key-value pairs to be encoded in the URL.
    case requestURLParameters(_ parameters: Parameters)

    case requestJSONBody(_ body: Encodable)
}

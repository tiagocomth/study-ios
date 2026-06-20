//
//  NetworkError.swift
//  Study
//
//  Created by Thiago de Jesus on 08/03/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {

    case invalidURL(message: String)
    case requestBuildFailed(message: String)
    case network(Error)
    case noResponse(message: String)
    case invalidStatusCode(codeStatus: Int, message: String)
    case unauthorized(message: String)
    case forbidden(message: String)
    case notFound(message: String)
    case emptyData(message: String)
    case decodingFailed(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(message: let message),
                .requestBuildFailed(message: let message),
                .noResponse(message: let message),
                .unauthorized(message: let message),
                .forbidden(message: let message),
                .notFound(message: let message),
                .emptyData(message: let message),
                .decodingFailed(message: let message):
            return message

        case .network(let error):
            return error.localizedDescription

        case .invalidStatusCode(codeStatus: let status, message: let message):
            return "\(message) (status code: \(status))"
        }
    }
}

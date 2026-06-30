//
//  JoinGroupRequestDTO.swift
//  Study
//

import Foundation

/// Corpo do `POST /groups/{id}/join`. A `password` só é enviada para grupos
/// privados; em grupos públicos fica `nil` e o encoder sintetizado a omite
/// (usa `encodeIfPresent`), resultando num corpo vazio `{}`.
struct JoinGroupRequestDTO: Encodable {
    let password: String?
}

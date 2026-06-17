//
//  KeychainService.swift
//  Study
//

import Foundation
import Security

/// Abstraction over secure storage, so the session layer can be tested with a mock.
protocol KeychainServicing: Sendable {
    func save(_ data: Data, for key: String) throws
    func read(for key: String) -> Data?
    func delete(for key: String) throws
}

extension KeychainServicing {
    /// Saves any `Encodable` value as JSON.
    func save<T: Encodable>(_ value: T, for key: String) throws {
        let data = try JSONEncoder().encode(value)
        try save(data, for: key)
    }

    /// Reads and decodes a value, returning `nil` if it is missing or corrupt.
    func read<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = read(for: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Saves a raw string (e.g. an auth token).
    func saveString(_ string: String, for key: String) throws {
        try save(Data(string.utf8), for: key)
    }

    /// Reads a raw string.
    func readString(for key: String) -> String? {
        guard let data = read(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

/// Keychain-backed implementation of `KeychainServicing`.
final class KeychainService: KeychainServicing {

    enum KeychainError: Error {
        case unexpectedStatus(OSStatus)
    }

    func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        // Replaces any existing entry for this key.
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func read(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        // Not finding the item is fine — it is already gone.
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

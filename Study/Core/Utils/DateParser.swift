//
//  DateParser.swift
//  Study
//

import Foundation

protocol DateParsing {
    func parse(_ string: String) -> Date?
}

struct ISO8601DateParser: DateParsing {
    private let standardFormatter = ISO8601DateFormatter()
    private let fractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    func parse(_ string: String) -> Date? {
        if let date = standardFormatter.date(from: string) {
            return date
        }
        return fractionalFormatter.date(from: string)
    }
}

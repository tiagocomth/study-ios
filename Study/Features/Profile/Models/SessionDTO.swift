//
//  SessionDTO.swift
//  Study
//
//  Created by Breno Marques on 24/06/26.
//

import Foundation

struct SessionDTO: Decodable {
    let sessionId: String
    let userId: String
    let categoryId: String
    let startedAt: String
    let endedAt: String
    let duration: Int

    func toDomain(dateParser: DateParsing = ISO8601DateParser()) -> Session {
        let startDate = dateParser.parse(startedAt) ?? Date()
        let endDate = dateParser.parse(endedAt) ?? Date()
        
        return Session(
            id: sessionId,
            userId: userId,
            categoryId: categoryId,
            startedAt: startDate,
            endedAt: endDate,
            duration: duration
        )
    }
}

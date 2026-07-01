//
//  AppRuntime.swift
//  Study
//

import Foundation
import SwiftData

enum AppRuntime {
    static let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

enum StudyModelContainerProvider {
    static let shared: ModelContainer = {
        do {
            if AppRuntime.isRunningTests {
                let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(for: StoredStudyCategory.self, configurations: configuration)
            }

            return try ModelContainer(for: StoredStudyCategory.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }()
}

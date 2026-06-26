//
//  OperationSyncResult.swift
//  Study
//

import Foundation

enum OperationSyncResult: Equatable {
    case completed
    case stoppedOnFailure
    case alreadyRunning
}

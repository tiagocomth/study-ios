//
//  TimerModeOption.swift
//  Study
//

import Foundation

enum TimerModeOption: CaseIterable, Equatable {
    case stopwatch
    case countdown

    var title: String {
        switch self {
        case .stopwatch:
            "Estudo com\nCronômetro"
        case .countdown:
            "Estudo com\nTimer Definido"
        }
    }

    var subtitle: String {
        switch self {
        case .stopwatch:
            "Registre seu tempo de estudo sem limite de duração."
        case .countdown:
            "Defina a duração da sua sessão de estudo."
        }
    }

    var symbolName: String {
        switch self {
        case .stopwatch:
            "stopwatch.fill"
        case .countdown:
            "timer"
        }
    }
}

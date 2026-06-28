//
//  StudySessionViewModel+Session.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import Foundation

// MARK: - Session State
extension StudySessionViewModel {
    func didTapPrimaryButton() {
        guard canStartTimer else { return }

        switch timerState {
        case .notStarted, .finished:
            selectedTimerModeOption = nil
            isTimerModePickerPresented = true
        case .running, .paused:
            // TODO: conectar acoes do footer ao fluxo de sessao em andamento.
            return
        }
    }

    func shouldDisableClick() -> Bool {
        categoryPendingDeletion != nil || isTimerModePickerPresented || isCountdownDurationPickerPresented
    }

    var canStartTimer: Bool {
        selectedCategoryId != nil
    }

    var primaryButtonTitle: String {
        switch timerState {
        case .notStarted, .finished:
            "Iniciar Timer"
        case .running:
            "Continuar Timer"
        case .paused:
            "Retomar Timer"
        }
    }

    var canConfirmTimerModeSelection: Bool {
        selectedTimerModeOption != nil
    }

    var canConfirmCountdownDurationSelection: Bool {
        countdownDurationInSeconds >= 300
    }
}

// MARK: - Timer Flow
extension StudySessionViewModel {
    func dismissTimerModePicker() {
        selectedTimerModeOption = nil
        isTimerModePickerPresented = false
    }

    func dismissTimerOverlays() {
        dismissTimerModePicker()
        dismissCountdownDurationPicker()
    }

    func selectTimerModeOption(_ option: TimerModeOption) {
        selectedTimerModeOption = option
    }

    func confirmTimerModeSelection() {
        guard let selectedTimerModeOption else { return }

        switch selectedTimerModeOption {
        case .stopwatch:
            // TODO: ligar configuracao e inicio real da sessao para cronometro.
            self.selectedTimerModeOption = nil
            isTimerModePickerPresented = false
        case .countdown:
            resetCountdownDuration()
            isTimerModePickerPresented = false
            isCountdownDurationPickerPresented = true
        }
    }

    func dismissCountdownDurationPicker() {
        isCountdownDurationPickerPresented = false
    }

    func navigateBackFromCountdownDurationPicker() {
        isCountdownDurationPickerPresented = false
        isTimerModePickerPresented = true
        selectedTimerModeOption = .countdown
    }

    func updateCountdownHoursText(_ text: String) {
        countdownHoursText = sanitizeCountdownText(text, maximum: 99)
    }

    func updateCountdownMinutesText(_ text: String) {
        countdownMinutesText = sanitizeCountdownText(text, maximum: 59)
    }

    func updateCountdownSecondsText(_ text: String) {
        countdownSecondsText = sanitizeCountdownText(text, maximum: 59)
    }

    func confirmCountdownDurationSelection() {
        guard canConfirmCountdownDurationSelection else { return }

        // TODO: ligar configuracao e inicio real da sessao de estudo com countdown.
        isCountdownDurationPickerPresented = false
    }
    
    func makeTimerViewState(from state: StudySessionTimerState) -> TimerViewState {
        let snapshot = TimerSnapshot(
            mode: state.mode,
            elapsedSeconds: state.elapsedSeconds,
            remainingSeconds: state.remainingSeconds
        )

        if let activeSession, activeSession.state == .finished {
            return .finished(snapshot)
        }

        if state.isRunning {
            return .running(snapshot)
        }

        if activeSession?.state == .paused {
            return .paused(snapshot)
        }

        return .notStarted
    }

    var countdownDurationInSeconds: Int {
        let hours = Int(countdownHoursText) ?? 0
        let minutes = Int(countdownMinutesText) ?? 0
        let seconds = Int(countdownSecondsText) ?? 0

        return (hours * 3600) + (minutes * 60) + seconds
    }

    func resetCountdownDuration() {
        countdownHoursText = "00"
        countdownMinutesText = "05"
        countdownSecondsText = "00"
    }

    func sanitizeCountdownText(_ text: String, maximum: Int) -> String {
        let digits = text.filter(\.isNumber)
        let truncatedDigits = String(digits.prefix(2))

        guard !truncatedDigits.isEmpty else {
            return ""
        }

        let value = min(Int(truncatedDigits) ?? 0, maximum)
        return String(format: "%02d", value)
    }
}

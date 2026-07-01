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

        selectedTimerModeOption = nil
        isTimerModePickerPresented = true
    }

    func shouldDisableClick() -> Bool {
        categoryPendingDeletion != nil || isTimerModePickerPresented || isCountdownDurationPickerPresented || isCreatingCategoryInline
    }

    var canStartTimer: Bool {
        selectedCategoryId != nil && categoryPendingDeletion == nil
    }

    var shouldShowTimerScreen: Bool {
        isTimerScreenPresented
    }

    var canConfirmTimerModeSelection: Bool {
        selectedTimerModeOption != nil
    }

    var canConfirmCountdownDurationSelection: Bool {
        countdownDurationInSeconds >= 300
    }

    var currentHeaderModeTitle: String {
        return currentTimerModeOption?.title.replacingOccurrences(of: "\n", with: " ") ?? "Selecione sua matéria"
    }

    var timerScreenTimerText: String {
        switch timerState {
        case .running(let snapshot), .paused(let snapshot), .finished(let snapshot):
            return formatTimerText(seconds: timerDisplaySeconds(from: snapshot))
        case .notStarted:
            return "00:00:00"
        }
    }

    var timerScreenTimerValue: Double {
        switch timerState {
        case .running(let snapshot), .paused(let snapshot), .finished(let snapshot):
            return Double(timerDisplaySeconds(from: snapshot))
        case .notStarted:
            return 0
        }
    }

    var timerToggleSymbolName: String {
        switch timerState {
        case .running:
            "pause.fill"
        case .paused, .notStarted, .finished:
            "play.fill"
        }
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
            isTimerModePickerPresented = false
            startStudySession(with: .stopwatch)
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

        isCountdownDurationPickerPresented = false
        startStudySession(with: .countdown(durationSeconds: countdownDurationInSeconds))
    }

    func didTapTimerToggle() {
        Task { [weak self] in
            guard let self else { return }

            do {
                switch timerState {
                case .running:
                    try await worker.pauseStudySession()
                case .paused:
                    try await worker.resumeStudySession()
                case .notStarted, .finished:
                    return
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func didTapFinishStudySession() {
        guard isFinishingStudySession == false else { return }
        isFinishingStudySession = true

        Task { [weak self] in
            guard let self else { return }

            do {
                try await worker.finishStudySession()
                reset(shouldDismissTimerScreen: false)
                try? await Task.sleep(for: .seconds(3))
                // TODO: substituir o sleep pela animação de finalizar a sessão.
                isTimerScreenPresented = false
            } catch {
                isFinishingStudySession = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func startStudySession(with timerMode: StudySessionTimerMode) {
        Task { [weak self] in
            guard let self else { return }
            guard let selectedCategoryId = self.selectedCategoryId else { return }

            do {
                try await worker.startStudySession(categoryId: selectedCategoryId, mode: timerMode)
                observeTimer()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func finishStudySessionIfCountdownCompleted(_ timerState: TimerViewState) {
        guard case .running(let snapshot) = timerState else { return }
        guard case .countdown = snapshot.mode else { return }
        guard (snapshot.remainingSeconds ?? 1) <= 0 else { return }

        didTapFinishStudySession()
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

    var currentTimerModeOption: TimerModeOption? {
        switch timerState {
        case .running(let snapshot), .paused(let snapshot), .finished(let snapshot):
            switch snapshot.mode {
            case .stopwatch:
                return .stopwatch
            case .countdown:
                return .countdown
            }
        case .notStarted:
            return nil
        }
    }

    func formatTimerText(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
    }

    func timerDisplaySeconds(from snapshot: TimerSnapshot) -> Int {
        switch snapshot.mode {
        case .stopwatch:
            return snapshot.elapsedSeconds
        case .countdown:
            return snapshot.remainingSeconds ?? snapshot.elapsedSeconds
        }
    }
}

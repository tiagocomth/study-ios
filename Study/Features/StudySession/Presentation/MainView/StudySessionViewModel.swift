//
//  StudySessionViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class StudySessionViewModel: ObservableObject {
    weak var coordinator: StudySessionCoordinatorProtocol?
    let worker: StudySessionWorkerProtocol
    private var hasStarted = false
    var categoryObservationTask: Task<Void, Never>?
    private var activeSessionObservationTask: Task<Void, Never>?
    private var timerObservationTask: Task<Void, Never>?

    @Published var editingCategoryName: String = ""

    @Published var viewState: StudySessionViewState = .loading
    @Published var categories: [StudyCategory] = []
    @Published private(set) var activeSession: LocalStudySession?
    @Published private(set) var timerState: TimerViewState = .notStarted
    @Published var errorMessage: String?

    @Published var selectedCategoryId: UUID?
    @Published var actionMenuCategoryId: UUID?
    @Published var editingCategoryId: UUID?
    @Published var categoryPendingDeletion: StudyCategory?
    @Published var isTimerModePickerPresented = false
    @Published var isCountdownDurationPickerPresented = false
    @Published var selectedTimerModeOption: TimerModeOption?
    @Published var countdownHoursText = "00"
    @Published var countdownMinutesText = "05"
    @Published var countdownSecondsText = "00"

    init(worker: StudySessionWorkerProtocol) {
        self.worker = worker
    }

    deinit {
        categoryObservationTask?.cancel()
        activeSessionObservationTask?.cancel()
        timerObservationTask?.cancel()
    }

    func onViewAppear() {
        guard !hasStarted else { return }

        hasStarted = true
        errorMessage = nil

        observeCategories()
        observeActiveStudySession()
        observeTimer()
        loadCategories()
    }

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
}

// MARK: - Observable
extension StudySessionViewModel {
    private func observeCategories() {
        categoryObservationTask?.cancel()
        categoryObservationTask = Task { [weak self] in
            guard let self else { return }

            for await categories in worker.categoryChanges() {
                handleCategoryUpdate(categories)
            }
        }
    }
    
    private func observeActiveStudySession() {
        activeSessionObservationTask?.cancel()
        activeSessionObservationTask = Task { [weak self] in
            guard let self else { return }

            let sessionChanges = await worker.activeStudySessionChanges()
            for await session in sessionChanges {
                activeSession = session
                syncSelectedCategory(with: session)
            }
        }
    }
    
    private func observeTimer() {
        timerObservationTask?.cancel()
        timerObservationTask = Task { [weak self] in
            guard let self else { return }

            do {
                let timerChanges = try await worker.timerChanges()

                for await timerState in timerChanges {
                    self.timerState = makeTimerViewState(from: timerState)
                }
            } catch let error as StudySessionError where error == .studySessionTimerNotConfigured {
                timerState = .notStarted
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

extension StudySessionViewModel {
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

    enum TimerViewState: Equatable {
        case notStarted
        case running(TimerSnapshot)
        case paused(TimerSnapshot)
        case finished(TimerSnapshot)
    }

    struct TimerSnapshot: Equatable {
        let mode: StudySessionTimerMode
        let elapsedSeconds: Int
        let remainingSeconds: Int?
    }
}

extension StudySessionViewModel {
    var canStartTimer: Bool {
        selectedCategoryId != nil
    }

    var shouldShowPrimaryButton: Bool {
        viewState == .content
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

private extension StudySessionViewModel {
    
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
}

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
}

private extension StudySessionViewModel {
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

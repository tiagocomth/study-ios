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
    @Published var selectedTimerModeOption: TimerModeOption?

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
        categoryPendingDeletion != nil || isTimerModePickerPresented
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

    func selectTimerModeOption(_ option: TimerModeOption) {
        selectedTimerModeOption = option
    }

    func confirmTimerModeSelection() {
        guard canConfirmTimerModeSelection else { return }

        // TODO: no proximo passo, ligar cada opcao ao fluxo de configuracao
        // e inicio real da sessao de estudos.
        selectedTimerModeOption = nil
        isTimerModePickerPresented = false
    }
}

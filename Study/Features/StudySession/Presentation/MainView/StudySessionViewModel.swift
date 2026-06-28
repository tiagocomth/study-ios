//
//  StudySessionViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class StudySessionViewModel: ObservableObject {
    weak var coordinator: StudySessionCoordinatorProtocol?
    private let worker: StudySessionWorkerProtocol
    private var hasStarted = false
    private var categoryObservationTask: Task<Void, Never>?
    private var activeSessionObservationTask: Task<Void, Never>?
    private var timerObservationTask: Task<Void, Never>?

    @Published private(set) var viewState: StudySessionViewState = .loading
    @Published private(set) var categories: [StudyCategory] = []
    @Published private(set) var activeSession: LocalStudySession?
    @Published private(set) var timerState: TimerViewState = .notStarted
    @Published private(set) var errorMessage: String?
    @Published var selectedCategoryId: UUID?

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

    func selectCategory(_ categoryId: UUID) {
        selectedCategoryId = categoryId
    }

    func didTapAddCategory() {
        coordinator?.presentCreateCategory()
    }

    func didTapPrimaryButton() {
        guard canStartTimer else { return }
        // TODO: apresentar fluxo de configuracao do timer e inicio da sessao.
    }
}

extension StudySessionViewModel {
    
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
}

private extension StudySessionViewModel {
    func loadCategories() {
        do {
            let categories = try worker.loadCategories { [weak self] refreshedCategories in
                self?.handleCategoryUpdate(refreshedCategories)
            }
            handleCategoryUpdate(categories)
        } catch {
            errorMessage = error.localizedDescription
            viewState = .error
        }
    }

    func observeCategories() {
        categoryObservationTask?.cancel()
        categoryObservationTask = Task { [weak self] in
            guard let self else { return }

            for await categories in worker.categoryChanges() {
                handleCategoryUpdate(categories)
            }
        }
    }

    func observeActiveStudySession() {
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

    func observeTimer() {
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

    func handleCategoryUpdate(_ categories: [StudyCategory]) {
        self.categories = categories
        errorMessage = nil

        if let selectedCategoryId,
           categories.contains(where: { $0.categoryId == selectedCategoryId }) == false {
            self.selectedCategoryId = nil
        }

        syncSelectedCategory(with: activeSession)

        if categories.isEmpty {
            viewState = .empty
        } else {
            viewState = .content
        }
    }

    func syncSelectedCategory(with session: LocalStudySession?) {
        guard
            let session,
            categories.contains(where: { $0.categoryId == session.categoryId })
        else {
            return
        }

        selectedCategoryId = session.categoryId
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
}

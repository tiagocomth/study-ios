//
//  StudySessionTrackerOrchestration.swift
//  Study
//

import Foundation

final class StudySessionTrackerOrchestration: StudySessionTrackerOrchestrationProtocol {
    private let studySessionTracker: StudySessionTrackerLocalProtocol
    private let studySessionActionOrchestration: StudySessionActionOrchestrationProtocol
    private var tasks: [Task<Void, Never>] = []
    
    init(
        studySessionTracker: StudySessionTrackerLocalProtocol,
        studySessionActionSender: StudySessionActionOrchestrationProtocol
    ) {
        self.studySessionTracker = studySessionTracker
        self.studySessionActionOrchestration = studySessionActionSender
    }
    
    func getActiveSession() async -> LocalStudySession? {
        await studySessionTracker.getActiveSession()
    }
    
    func start(categoryId: UUID) async throws {
        let action = try await studySessionTracker.start(categoryId: categoryId)
        await send(action)
    }
    
    func pause() async throws {
        let action = try await studySessionTracker.pause()
        await send(action)
    }
    
    func resume() async throws {
        let action = try await studySessionTracker.resume()
        await send(action)
    }
    
    func finish() async throws {
        let action = try await studySessionTracker.finish()
        await send(action)
    }
    
    deinit {
        for task in tasks {
            task.cancel()
        }
    }
}

private extension StudySessionTrackerOrchestration {
    func send(_ action: StudySessionTrackerAction) async {
        let task = Task { [studySessionActionOrchestration] in
            do {
                try await studySessionActionOrchestration.send(action)
            } catch {}
        }
        
        await MainActor.run {
            tasks.append(task)
        }
    }
}

//
//  FIFOGuardTests.swift
//  StudyTests
//

import Testing
import Foundation
@testable import Study

@MainActor
@Suite("FIFO Guard", .serialized)
struct FIFOGuardTests {
    private let userId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!

    @Test("category create enqueues instead of calling backend when queue already has pending operations")
    func categoryCreateEnqueuesWhenQueueIsNotEmpty() async throws {
        let categoryAPI = CategoryRemoteSpy()
        let categoryLocal = CategoryStoreLocalSpy()
        let operationManager = OperationManagerSpy(dispatchResults: [.enqueued])
        let manager = CategoryManager(
            categoryAPI: categoryAPI,
            categoryLocal: categoryLocal,
            operationManager: operationManager,
            currentUserId: { userId },
            makeId: { UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")! },
            now: { Date(timeIntervalSince1970: 1_719_324_800) }
        )

        let created = try manager.create(CreateCategoryDTO(name: "Math"))
        await settleBackgroundWork()

        #expect(created.name == "Math")
        #expect(await categoryAPI.createCallCount == 0)
        #expect(categoryLocal.savedCategories.count == 1)
        #expect(await operationManager.dispatchedKinds == [
            .createCategory(CreateCategoryDTO(name: "Math"))
        ])
        #expect(await operationManager.enqueuedKinds.isEmpty)
    }

    @Test("study session start enqueues instead of calling backend when queue already has pending operations")
    func studySessionStartEnqueuesWhenQueueIsNotEmpty() async throws {
        let categoryId = UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!
        let startDTO = StartStudySessionDTO(
            sessionId: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
            startDate: Date(timeIntervalSince1970: 1_719_324_800),
            categoryId: categoryId
        )
        let tracker = StudySessionTrackerLocalSpy(startAction: .started(startDTO))
        let studySessionAPI = StudySessionRemoteSpy()
        let operationManager = OperationManagerSpy(dispatchResults: [.enqueued])
        let manager = StudySessionManager(
            studySessionTracker: tracker,
            studySessionAPI: studySessionAPI,
            operationManager: operationManager,
            currentUserId: { userId }
        )

        try await manager.start(categoryId: categoryId)
        await settleBackgroundWork()

        #expect(await studySessionAPI.startCallCount == 0)
        #expect(await operationManager.dispatchedKinds == [
            .startStudySession(startDTO)
        ])
        #expect(await operationManager.enqueuedKinds.isEmpty)
    }

    @Test("resumed and finished session enqueues both operations in order when queue already has pending operations")
    func resumedAndFinishedEnqueuesBothOperationsInOrder() async throws {
        let sessionId = UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!
        let resumeDTO = ResumeStudySessionDTO(endedAt: Date(timeIntervalSince1970: 1_719_324_900))
        let endDTO = EndStudySessionDTO(endDate: Date(timeIntervalSince1970: 1_719_325_000))
        let tracker = StudySessionTrackerLocalSpy(
            finishAction: .resumedAndFinished(sessionId: sessionId, resume: resumeDTO, end: endDTO)
        )
        let studySessionAPI = StudySessionRemoteSpy()
        let operationManager = OperationManagerSpy(dispatchResults: [.enqueued])
        let manager = StudySessionManager(
            studySessionTracker: tracker,
            studySessionAPI: studySessionAPI,
            operationManager: operationManager,
            currentUserId: { userId }
        )

        try await manager.finish()
        await settleBackgroundWork()

        #expect(await studySessionAPI.resumeCallCount == 0)
        #expect(await studySessionAPI.finishCallCount == 0)
        #expect(await operationManager.dispatchedKinds == [
            .resumeStudySession(id: sessionId, dto: resumeDTO)
        ])
        #expect(await operationManager.enqueuedKinds == [
            .endStudySession(id: sessionId, dto: endDTO)
        ])
    }

    private func settleBackgroundWork() async {
        for _ in 0..<10 {
            await Task.yield()
        }
    }
}

@MainActor
private final class CategoryStoreLocalSpy: CategoryStoreLocalProtocol {
    var savedCategories: [StudyCategory] = []
    var categoriesById: [UUID: StudyCategory] = [:]

    func categoryChanges(userId: UUID) -> AsyncStream<[StudyCategory]> {
        AsyncStream { continuation in
            continuation.yield(savedCategories.filter { $0.userId == userId })
            continuation.finish()
        }
    }

    func restoreState(for userId: UUID) async -> RestoreState { .restored }
    func ensureRestored(userId: UUID) async {}
    func getAll(userId: UUID) throws(CategoryStoreLocalError) -> [StudyCategory] { savedCategories.filter { $0.userId == userId } }
    func getById(_ id: UUID, userId: UUID) throws(CategoryStoreLocalError) -> StudyCategory? { categoriesById[id] }
    func saveAll(_ categories: [StudyCategory]) throws(CategoryStoreLocalError) {}
    func save(_ category: StudyCategory) throws(CategoryStoreLocalError) {
        savedCategories.append(category)
        categoriesById[category.categoryId] = category
    }
    func delete(id: UUID, userId: UUID) throws(CategoryStoreLocalError) { categoriesById[id] = nil }
    func rollbackCreate(id: UUID, userId: UUID) throws(CategoryStoreLocalError) {}
    func rollbackUpdate(previousCategory: StudyCategory) throws(CategoryStoreLocalError) {}
    func rollbackDelete(deletedCategory: StudyCategory) throws(CategoryStoreLocalError) {}
}

private actor OperationManagerSpy: OperationManagerProtocol {
    let hasPending: Bool
    var dispatchResults: [OperationDispatchResult]
    var dispatchedKinds: [PendingOfflineOperationKind] = []
    var enqueuedKinds: [PendingOfflineOperationKind] = []

    init(
        hasPending: Bool = true,
        dispatchResults: [OperationDispatchResult] = [.enqueued]
    ) {
        self.hasPending = hasPending
        self.dispatchResults = dispatchResults
    }

    func hasPendingOperations(userId: UUID) async -> Bool {
        hasPending
    }

    func dispatch(
        _ kind: PendingOfflineOperationKind,
        userId: UUID,
        sendRemote: () async throws(NetworkError) -> Void
    ) async -> OperationDispatchResult {
        dispatchedKinds.append(kind)

        guard !dispatchResults.isEmpty else {
            return .enqueued
        }

        return dispatchResults.removeFirst()
    }

    func enqueue(_ kind: PendingOfflineOperationKind, userId: UUID) async throws {
        enqueuedKinds.append(kind)
    }
}

private actor StudySessionLocalSpyState {
    var startAction: StudySessionTrackerAction?
    var finishAction: StudySessionTrackerAction?

    init(startAction: StudySessionTrackerAction?, finishAction: StudySessionTrackerAction?) {
        self.startAction = startAction
        self.finishAction = finishAction
    }
}

private struct StudySessionTrackerLocalSpy: StudySessionTrackerLocalProtocol {
    private let state: StudySessionLocalSpyState

    init(
        startAction: StudySessionTrackerAction? = nil,
        finishAction: StudySessionTrackerAction? = nil
    ) {
        self.state = StudySessionLocalSpyState(startAction: startAction, finishAction: finishAction)
    }

    func sessionChanges(userId: UUID) async -> AsyncStream<LocalStudySession?> {
        AsyncStream { continuation in
            continuation.yield(nil)
            continuation.finish()
        }
    }

    func restoreState(for userId: UUID) async -> RestoreState { .restored }
    func ensureRestored(userId: UUID) async {}
    func getActiveSession(userId: UUID) async -> LocalStudySession? { nil }

    func start(categoryId: UUID, userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction {
        guard let action = await state.startAction else {
            throw .sessionNotFound
        }
        return action
    }

    func pause(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction { throw .sessionNotFound }
    func resume(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction { throw .sessionNotFound }

    func finish(userId: UUID) async throws(StudySessionTrackerLocalError) -> StudySessionTrackerAction {
        guard let action = await state.finishAction else {
            throw .sessionNotFound
        }
        return action
    }

    func clear(userId: UUID) async {}
}

private actor CategoryRemoteSpy: CategoryAPIProtocol {
    var createCallCount = 0

    func getAll() async throws(NetworkError) -> [StudyCategory] { [] }
    func getById(_ id: UUID) async throws(NetworkError) -> StudyCategory {
        throw .notFound(message: "not implemented")
    }
    func create(_ dto: CreateCategoryDTO) async throws(NetworkError) { createCallCount += 1 }
    func update(id: UUID, dto: UpdateCategoryDTO) async throws(NetworkError) {}
    func delete(id: UUID) async throws(NetworkError) {}
}

private actor StudySessionRemoteSpy: StudySessionAPIProtocol {
    var startCallCount = 0
    var resumeCallCount = 0
    var finishCallCount = 0

    func start(_ dto: StartStudySessionDTO) async throws(NetworkError) { startCallCount += 1 }
    func pause(id: UUID, dto: PauseStudySessionDTO) async throws(NetworkError) {}
    func resume(id: UUID, dto: ResumeStudySessionDTO) async throws(NetworkError) { resumeCallCount += 1 }
    func finish(id: UUID, dto: EndStudySessionDTO) async throws(NetworkError) { finishCallCount += 1 }
    func delete(id: UUID) async throws(NetworkError) {}
}

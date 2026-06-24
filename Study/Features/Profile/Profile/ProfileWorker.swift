//
//  ProfileWorker.swift
//  Study
//

import Foundation

protocol ProfileWorkerProtocol {
    func updateProfile(request: UpdateProfileRequest) async throws(NetworkError) -> GetProfileResponse
    func getProfile(id: String) async throws(NetworkError) -> UpdateProfileResponse
    func getSessions() async throws(NetworkError) -> GetMySessionsResponse
    func logout()
}

final class ProfileWorker: ProfileWorkerProtocol {
    
    private let service: ProfileServiceProtocol
    private let userSession: UserSessionProtocol

    init(service: ProfileServiceProtocol, userSession: UserSessionProtocol) {
        self.service = service
        self.userSession = userSession
    }

    func updateProfile(request: UpdateProfileRequest) async throws(NetworkError) -> GetProfileResponse {
        let response = try await service.updateProfile(request: request)
        
        let currentUser = userSession.currentUser
        let updatedUser = User(
            id: response.userId,
            name: response.name,
            photo: response.photoId,
            individualHoursTotal: currentUser?.individualHoursTotal ?? 0.0,
            groupHoursTotal: currentUser?.groupHoursTotal ?? 0.0
        )
        userSession.update(user: updatedUser)
        return response
    }

    func getProfile(id: String) async throws(NetworkError) -> UpdateProfileResponse {
        let response = try await service.getProfile(id: id)
        
        if response.data.userId == userSession.currentUser?.id {
            let updatedUser = User(
                id: response.data.userId,
                name: response.data.name,
                photo: response.data.photoId,
                individualHoursTotal: userSession.currentUser?.individualHoursTotal ?? 0.0,
                groupHoursTotal: userSession.currentUser?.groupHoursTotal ?? 0.0
            )
            userSession.update(user: updatedUser)
        }
        return response
    }

    func getSessions() async throws(NetworkError) -> GetMySessionsResponse {
        return try await service.getSessions()
    }

    func logout() {
        userSession.logout()
    }
}

//
//  EditProfileWorker.swift
//  Study
//

import Foundation

protocol EditProfileWorkerProtocol {
    func getMyProfile() async throws(NetworkError) -> UpdateProfileResponse
    func updateProfile(request: UpdateProfileRequest) async throws(NetworkError) -> GetProfileResponse
}

final class EditProfileWorker: EditProfileWorkerProtocol {
    
    private let service: ProfileServiceProtocol
    private let userSession: UserSessionProtocol

    init(service: ProfileServiceProtocol, userSession: UserSessionProtocol) {
        self.service = service
        self.userSession = userSession
    }

    func getMyProfile() async throws(NetworkError) -> UpdateProfileResponse {
        guard let userId = userSession.currentUser?.id else {
            throw NetworkError.unauthorized(message: "Nenhum usuário logado.")
        }
        return try await service.getProfile(id: userId)
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
}

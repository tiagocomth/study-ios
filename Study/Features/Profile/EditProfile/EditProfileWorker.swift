//
//  EditProfileWorker.swift
//  Study
//

import Foundation

protocol EditProfileWorkerProtocol {
    func getMyProfile() async throws(NetworkError) -> UserProfileDTO
    func updateProfile(request: UpdateProfileRequest) async throws(NetworkError) -> UpdateProfileResponse
}

final class EditProfileWorker: EditProfileWorkerProtocol {
    private let service: ProfileServiceProtocol
    private let userSession: UserSessionProtocol

    init(service: ProfileServiceProtocol, userSession: UserSessionProtocol) {
        self.service = service
        self.userSession = userSession
    }
    
    private var currentUser: User? {
        userSession.currentUser
    }

    func getMyProfile() async throws(NetworkError) -> UserProfileDTO {
        guard let userId = currentUser?.id else {
            throw NetworkError.unauthorized(message: "Nenhum usuário logado.")
        }
        return try await service.getProfile(id: userId)
    }

    func updateProfile(request: UpdateProfileRequest) async throws(NetworkError) -> UpdateProfileResponse {
        let response = try await service.updateProfile(request: request)

        let updatedUser = User(
            id: response.data.userId,
            name: response.data.name,
            isPremium: response.data.isPremium,
            photo: response.data.photoId,
            individualHoursTotal: currentUser?.individualHoursTotal ?? 0.0,
            groupHoursTotal: currentUser?.groupHoursTotal ?? 0.0
        )
        userSession.update(user: updatedUser)
        return response
    }
}

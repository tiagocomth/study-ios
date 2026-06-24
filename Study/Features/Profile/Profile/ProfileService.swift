//
//  ProfileService.swift
//  Study
//
//  Created by Breno Marques on 23/06/26.
//

import Foundation

protocol ProfileServiceProtocol {
    func updateProfile(request: UpdateProfileRequest) async throws(NetworkError) -> GetProfileResponse
    func getProfile(id: String) async throws(NetworkError) -> UpdateProfileResponse
    func getSessions() async throws(NetworkError) -> GetMySessionsResponse
}

final class ProfileService: ProfileServiceProtocol {
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func updateProfile(request: UpdateProfileRequest) async throws(NetworkError) -> GetProfileResponse {
        let endpoint = ProfileEndpoint.updateProfile(request)
        return try await apiClient.request(endpoint)
    }
    
    func getProfile(id: String) async throws(NetworkError) -> UpdateProfileResponse {
        let endpoint = ProfileEndpoint.getProfile(id: id)
        return try await apiClient.request(endpoint)
    }
    
    func getSessions() async throws(NetworkError) -> GetMySessionsResponse {
        let endpoint = ProfileEndpoint.getSessions
        return try await apiClient.request(endpoint)
    }
}

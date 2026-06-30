//
//  SidebarViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class SidebarViewModel: ObservableObject {
    @Published var myGroups: [StudyGroup] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadMyGroups() async {
        isLoading = true
        error = nil
        do {
            let groups: [StudyGroup] = try await apiClient.request(GroupsAPI.myGroups)
            self.myGroups = groups
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

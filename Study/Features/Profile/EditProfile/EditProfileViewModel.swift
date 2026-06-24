//
//  EditProfileViewModel.swift
//  Study
//

import Foundation
import Combine

@MainActor
final class EditProfileViewModel: ObservableObject {
    
    weak var coordinator: EditProfileCoordinatorProtocol?
    private let worker: EditProfileWorkerProtocol

    @Published var name: String = ""
    @Published var photoId: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSuccess: Bool = false

    init(worker: EditProfileWorkerProtocol) {
        self.worker = worker
    }

    
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            let profileResponse = try await worker.getMyProfile()
            self.name = profileResponse.data.name
            if let photoStr = profileResponse.data.photoId, let photoInt = Int(photoStr) {
                self.photoId = photoInt
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveProfile() async {
        isLoading = true
        errorMessage = nil

        let request = UpdateProfileRequest(name: name, photoId: photoId)
        do {
            _ = try await worker.updateProfile(request: request)
            isSuccess = true
            coordinator?.dismissEditProfile()
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func dismiss() {
        coordinator?.dismissEditProfile()
    }
}

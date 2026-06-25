//
//  ProfileWorker.swift
//  Study
//

import Foundation

protocol ProfileWorkerProtocol {
    var currentUser: User? { get }
    func getMyProfile() async throws(NetworkError) -> Profile
    func logout()
}

final class ProfileWorker: ProfileWorkerProtocol {
    private let service: ProfileServiceProtocol
    private let userSession: UserSessionProtocol

    var currentUser: User? {
        userSession.currentUser
    }

    init(service: ProfileServiceProtocol, userSession: UserSessionProtocol) {
        self.service = service
        self.userSession = userSession
    }

    func getMyProfile() async throws(NetworkError) -> Profile {
        guard let userId = userSession.currentUser?.id else {
            throw NetworkError.unauthorized(message: "Nenhum usuário logado.")
        }
        
        let profileDTO = try await service.getProfile(id: userId)
        let sessionsResponse = try await service.getSessions()
        
        let updatedUser = User(
            id: profileDTO.userId,
            name: profileDTO.name,
            photo: profileDTO.photoId,
            individualHoursTotal: userSession.currentUser?.individualHoursTotal ?? 0.0,
            groupHoursTotal: userSession.currentUser?.groupHoursTotal ?? 0.0
        )
        userSession.update(user: updatedUser)
        
        let sessions = sessionsResponse.sessions.map { $0.toDomain() }
        let (todayHours, weekHours, monthHours) = calculateHours(for: sessions)
        
        return Profile(
            id: profileDTO.userId,
            name: profileDTO.name,
            isPremium: profileDTO.isPremium,
            photoId: profileDTO.photoId,
            hoursStudiedToday: todayHours,
            hoursStudiedThisWeek: weekHours,
            hoursStudiedThisMonth: monthHours,
            sessions: sessions
        )
    }

    func logout() {
        userSession.logout()
    }
    
    // MARK: - Study Hours Calculation
    
    private func calculateHours(for sessions: [Session]) -> (today: Double, week: Double, month: Double) {
        let calendar = Calendar.current
        let now = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now),
              let monthInterval = calendar.dateInterval(of: .month, for: now) else {
            return (0.0, 0.0, 0.0)
        }
        
        let todaySessions = sessions.filter { calendar.isDateInToday($0.startedAt) }
        let weekSessions = sessions.filter { $0.startedAt >= weekInterval.start && $0.startedAt < weekInterval.end }
        let monthSessions = sessions.filter { $0.startedAt >= monthInterval.start && $0.startedAt < monthInterval.end }
        
        let todayHours = Double(todaySessions.reduce(0) { $0 + $1.duration }) / 3600.0
        let weekHours = Double(weekSessions.reduce(0) { $0 + $1.duration }) / 3600.0
        let monthHours = Double(monthSessions.reduce(0) { $0 + $1.duration }) / 3600.0
        
        return (todayHours, weekHours, monthHours)
    }
}

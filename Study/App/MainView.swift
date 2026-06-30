//
//  MainView.swift
//  Study
//

import SwiftUI

struct MainView: View {
    @ObservedObject var session: UserSessionService
    let appWorker: AppWorker
    
    @State private var selectedTab: AppTab? = .studySessions
    @State private var isSidebarExpanded: Bool = true
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Detail / Main Content
            ZStack {
                switch selectedTab {
                case .studySessions:
                    CoordinateView(coordinator: appWorker.makeStudySessionCoordinator())
                case .exploreGroups:
                    CoordinateView(coordinator: appWorker.makeGroupCoordinator(
                        factory: GroupFactory(apiClient: appWorker.apiClient, userSession: appWorker.userSessionService)
                    ))
                case .myGroups:
                    Text("Meus Grupos (Em breve)")
                        .navigationTitle("Meus Grupos")
                case .myGroup(let id):
                    // Placeholder since we don't have GroupDetailsCoordinator implementation here
                    Text("Grupo (Em breve)")
                        .navigationTitle("Grupo")
                case .profile:
                    CoordinateView(coordinator: appWorker.makeProfileCoordinator(
                        factory: ProfileFactory(apiClient: appWorker.apiClient, userSession: appWorker.userSessionService, paymentService: appWorker.paymentService)
                    ))
                case .none:
                    Text("Selecione um item no menu")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //TODO: implementar cor atual do app
            .background(Color.clear)
            
            SidebarView(
                selection: $selectedTab,
                isExpanded: $isSidebarExpanded,
                viewModel: SidebarViewModel(apiClient: appWorker.apiClient)
            )
        }
    }
}

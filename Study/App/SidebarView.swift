//
//  SidebarView.swift
//  Study
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: AppTab?
    @Binding var isExpanded: Bool
    @State private var isGroupsListExpanded: Bool = true
    @StateObject private var viewModel: SidebarViewModel
    
    // Layout Constants
    private let expandedWidth: CGFloat = 240
    private let collapsedWidth: CGFloat = 70
    private let horizontalPadding: CGFloat = 12
    
    init(selection: Binding<AppTab?>, isExpanded: Binding<Bool>, viewModel: SidebarViewModel) {
        self._selection = selection
        self._isExpanded = isExpanded
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        // TODO: Design System - Ajustar espaçamento
        VStack(alignment: .leading, spacing: 0) {
            
            // Toggle Button (Fixed at the top)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sidebar.left")
                        .font(.title3)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // TODO: Design System - Ajustar padding
            .padding(.top, 24)
            .padding(.bottom, 8)
            
            // Scrollable Content
            ScrollView(showsIndicators: false) {
                // TODO: Design System - Ajustar espaçamento
                VStack(alignment: .leading, spacing: 24) {
                    // Top buttons
                    // TODO: Design System - Ajustar espaçamento
                    VStack(alignment: .leading, spacing: 16) {
                        SidebarButton(
                            title: "Estudos",
                            icon: "books.vertical",
                            isSelected: selection == .studySessions,
                            isExpanded: isExpanded
                        ) {
                            selection = .studySessions
                        }
                        
                        SidebarButton(
                            title: "Buscar Grupos",
                            icon: "person.2",
                            isSelected: selection == .exploreGroups,
                            isExpanded: isExpanded
                        ) {
                            selection = .exploreGroups
                        }
                    }
                    
                    // Groups Section
                    // TODO: Design System - Ajustar espaçamento
                    VStack(alignment: .leading, spacing: 16) {
                        if isExpanded {
                            // Button when expanded
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isGroupsListExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Meus Grupos")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: true, vertical: false)
                                    
                                    Spacer(minLength: 0)
                                    
                                    Image(systemName: isGroupsListExpanded ? "chevron.down" : "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(4) // Extra tap area
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        } else {
                            // Divider when collapsed
                            Divider()
                                .frame(width: collapsedWidth - (horizontalPadding * 2)) // fills collapsed area minus padding
                                .transition(.opacity)
                        }
                        if isGroupsListExpanded {
                            if viewModel.isLoading {
                                ProgressView()
                            } else if viewModel.myGroups.isEmpty && isExpanded {
                                Text("Nenhum grupo encontrado.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                // TODO: Design System - Ajustar espaçamento
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(viewModel.myGroups, id: \.id) { group in
                                        SidebarGroupButton(
                                            title: group.name,
                                            isSelected: selection == .myGroup(id: group.id),
                                            isExpanded: isExpanded
                                        ) {
                                            selection = .myGroup(id: group.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // TODO: Design System - Ajustar padding
                .padding(.top, 8)
            }
            
            Spacer(minLength: 0)
            
            // Profile Button
            SidebarButton(
                title: "Perfil",
                icon: "person",
                isSelected: selection == .profile,
                isExpanded: isExpanded
            ) {
                selection = .profile
            }
            // TODO: Design System - Ajustar padding
            .padding(.bottom, 32)
        }
        .padding(.horizontal, horizontalPadding)
        .task {
            await viewModel.loadMyGroups()
        }
        .frame(width: expandedWidth, alignment: .leading)
        .frame(width: isExpanded ? expandedWidth : collapsedWidth, alignment: .leading)
        .clipped()
        // TODO: implementar cor atual do app
        .background(Color.clear)
    }
}

struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            // TODO: Design System - Ajustar espaçamento
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                if isExpanded {
                    Text(title)
                        .font(isSelected ? .body.bold() : .body)
                        .fixedSize(horizontal: true, vertical: false)
                        .transition(.opacity)
                    Spacer(minLength: 0)
                }
            }
            .foregroundColor(isSelected ? .primary : .secondary)
            // TODO: Design System - Ajustar padding
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .background(isSelected ? Color.gray.opacity(0.15) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct SidebarGroupButton: View {
    let title: String
    let isSelected: Bool
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            // TODO: Design System - Ajustar espaçamento
            HStack(spacing: 12) {
                if isExpanded {
                    Text(title)
                        .font(isSelected ? .body.bold() : .body)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .transition(.opacity)
                    Spacer(minLength: 0)
                }
            }
            .frame(minHeight: 24)
            .foregroundColor(isSelected ? .primary : .primary.opacity(0.8))
            // TODO: Design System - Ajustar padding
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .background(isSelected ? Color.gray.opacity(0.15) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

//
//  StudySessionCategoryCardView.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import SwiftUI

struct StudySessionCategoryCardView: View {
    @Binding var isActionMenuPresented: Bool
    @Binding var editingName: String
    
    let categoryName: String
    let isSelected: Bool
    let isEditing: Bool
    
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSubmitEditing: () -> Void
    
    var body: some View {
        StudySessionCardView(
            editingName: $editingName,
            categoryName: categoryName,
            isEditing: isEditing,
            isSelected: isSelected,
            action: onSelect,
            onSubmitEditing: onSubmitEditing
        )
        .popover(isPresented: $isActionMenuPresented, arrowEdge: .bottom) {
            StudySessionCategoryActionsMenuView(
                onEdit: onEdit,
                onDelete: onDelete
            )
        }
        .overlay {
            StudySessionContextClickCaptureView {
                isActionMenuPresented = true
            }
        }
    }
}

#Preview {
    StudySessionCategoryCardView(
        isActionMenuPresented: .constant(false),
        editingName: .constant("Português"),
        categoryName: "Português",
        isSelected: false,
        isEditing: false,
        onSelect: {},
        onEdit: {},
        onDelete: {},
        onSubmitEditing: {}
    )
    .frame(width: 100)
    .padding()
}

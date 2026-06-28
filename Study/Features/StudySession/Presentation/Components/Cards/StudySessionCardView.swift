//
//  StudySessionCardView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionCardView: View {
    
    @Binding var editingName: String

    let categoryName: String
    let isEditing: Bool
    let isSelected: Bool
    let action: () -> Void
    var onSubmitEditing: () -> Void = {}

    @FocusState private var isEditingFieldFocused: Bool

    var body: some View {
        VStack {
            Button(action: action) {
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.small)
                            .stroke()
                            .foregroundStyle(isSelected ? .red : .neutralColorblack)
                    }
            }
            .buttonStyle(.studyStyle)
            .aspectRatio(1, contentMode: .fit)
            
            categoryNameView
        }
        .onChange(of: isEditing) { _, isEditing in
            isEditingFieldFocused = isEditing
        }
    }
}

private extension StudySessionCardView {
    @ViewBuilder
    var categoryNameView: some View {
        if isEditing {
            TextField("", text: $editingName)
                .textFieldStyle(.plain)
                .foregroundStyle(.neutralColorblack)
                .padding(.horizontal)
                .frame(width: 120, height: 20)
                .background(AppColors.neutralWhite)
                .overlay {
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 1.5)
                }
                .focused($isEditingFieldFocused)
                .onAppear {
                    isEditingFieldFocused = true
                }
                .onSubmit(onSubmitEditing)
        } else {
            Text(categoryName)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .red : AppColors.neutralBlack)
                .lineLimit(1)
                .frame(width: 120)
        }
    }
}

#Preview {
    StudySessionCardView(
        editingName: .constant("Português"),
        categoryName: "Português",
        isEditing: false,
        isSelected: false
    ) { }
}

//
//  StudySessionEmptyView.swift
//  Study
//
//  Created by Caio Mandarino on 27/06/26.
//

import SwiftUI

struct StudySessionEmptyView: View {
    @Binding var isCreatingCategoryInline: Bool
    @Binding var creatingCategoryName: String

    let onAddCategory: () -> Void
    let onSubmitCreatingCategory: () -> Void

    var body: some View {
        VStack(spacing: GlobalConfiguration.normalSpacing) {
            Spacer()

            Group {
                if isCreatingCategoryInline {
                    StudySessionCardView(
                        editingName: $creatingCategoryName,
                        categoryName: "",
                        isEditing: true,
                        isSelected: false,
                        action: {},
                        onSubmitEditing: onSubmitCreatingCategory
                    )
                } else {
                    StudySessionAddCardView(action: onAddCategory)
                }
            }
            .frame(maxWidth: 100, alignment: .top)

            Text("Parece que você ainda não adicionou\nnenhuma matéria ainda!")
                .font(.title2)
                .foregroundStyle(AppColors.neutralGray)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StudySessionEmptyView(
        isCreatingCategoryInline: .constant(false),
        creatingCategoryName: .constant(""),
        onAddCategory: {},
        onSubmitCreatingCategory: {}
    )
}

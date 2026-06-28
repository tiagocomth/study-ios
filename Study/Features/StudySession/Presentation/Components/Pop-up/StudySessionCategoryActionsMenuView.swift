//
//  StudySessionCategoryActionsMenuView.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import SwiftUI

struct StudySessionCategoryActionsMenuView: View {
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            actionRow(title: "Editar", action: onEdit)

            Divider()
                .overlay(AppColors.neutralBlack)

            actionRow(title: "Excluir Matéria", action: onDelete)
        }
        .frame(width: 220)
        .background(AppColors.primaryLight)
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.small)
                .stroke(AppColors.neutralBlack, lineWidth: AppBorder.width)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
        .shadow(color: .black, radius: AppShadow.radius, y: AppShadow.y)
    }
}

private extension StudySessionCategoryActionsMenuView {
    func actionRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.neutralBlack)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(GlobalConfiguration.normalPadding)
    }
}

#Preview {
    StudySessionCategoryActionsMenuView(
        onEdit: {},
        onDelete: {}
    )
    .padding(40)
    .background(Color.gray.opacity(0.2))
}

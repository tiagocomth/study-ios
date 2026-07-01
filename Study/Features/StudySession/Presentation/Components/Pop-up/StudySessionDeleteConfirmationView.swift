//
//  StudySessionDeleteConfirmationView.swift
//  Study
//
//  Created by Caio Mandarino on 28/06/26.
//

import SwiftUI

struct StudySessionDeleteConfirmationView: View {
    let title: String
    let onCancel: () -> Void
    let onConfirmDelete: () -> Void

    init(
        title: String = "Deseja Excluir sua matéria?",
        onCancel: @escaping () -> Void,
        onConfirmDelete: @escaping () -> Void
    ) {
        self.title = title
        self.onCancel = onCancel
        self.onConfirmDelete = onConfirmDelete
    }

    var body: some View {
        VStack(spacing: .zero) {
            VStack(spacing: GlobalConfiguration.normalSpacing) {
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .stroke(AppColors.neutralBlack, lineWidth: 1)
                    .frame(width: 100, height: 100)

                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.neutralBlack)
                    .multilineTextAlignment(.center)
            }
            .padding(GlobalConfiguration.normalPadding)

            Divider()
                .overlay(AppColors.neutralBlack)

            HStack {
                footerButton(
                    title: "Cancelar",
                    color: .blue,
                    action: onCancel
                )

                Divider()
                    .overlay(AppColors.neutralBlack)

                footerButton(
                    title: "Excluir",
                    color: .red,
                    action: onConfirmDelete
                )
            }
            .frame(maxHeight: 60)
        }
        .frame(width: 360)
        .background(AppColors.primaryLight)
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.small)
                .stroke(AppColors.neutralBlack, lineWidth: AppBorder.width)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
        .shadow(color: .black, radius: AppShadow.radius, y: AppShadow.y)
    }
}

private extension StudySessionDeleteConfirmationView {
    func footerButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StudySessionDeleteConfirmationView(
        onCancel: {},
        onConfirmDelete: {}
    )
    .padding(40)
    .background(Color.gray.opacity(0.2))
}

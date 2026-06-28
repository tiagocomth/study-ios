//
//  StudySessionPickerContainerView.swift
//  Study
//

import SwiftUI

struct StudySessionPickerContainerView<Content: View>: View {
    let spacing: CGFloat
    let buttonTitle: String
    let canConfirm: Bool
    let onBack: () -> Void
    let onConfirm: () -> Void
    @ViewBuilder let content: () -> Content

    init(
        spacing: CGFloat = GlobalConfiguration.largeSpacing,
        buttonTitle: String = "Iniciar Estudos",
        canConfirm: Bool,
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.buttonTitle = buttonTitle
        self.canConfirm = canConfirm
        self.onBack = onBack
        self.onConfirm = onConfirm
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColors.neutralBlack)
                    .frame(maxWidth: 25, maxHeight: 25)
            }
            .buttonStyle(.studyStyle)

            content()
                .frame(maxWidth: .infinity)

            Spacer()
            
            Button(action: onConfirm) {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!canConfirm)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
        .padding(GlobalConfiguration.normalPadding)
        .background(AppColors.neutralWhite)
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.small)
                .stroke(AppColors.neutralBlack, lineWidth: AppBorder.width)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
        .shadow(color: .black, radius: AppShadow.radius, y: AppShadow.y)
    }
}

#Preview {
    StudySessionPickerContainerView(
        canConfirm: true,
        onBack: {},
        onConfirm: {}
    ) {
        Rectangle()
            .fill(AppColors.primaryLight)
            .frame(height: 220)
    }
    .frame(width: 600, height: 500)
    .padding(40)
    .background(Color.gray.opacity(0.3))
}

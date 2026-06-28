//
//  StudySessionCountdownDurationPickerView.swift
//  Study
//

import SwiftUI

struct StudySessionCountdownDurationPickerView: View {
    @Binding var hoursText: String
    @Binding var minutesText: String
    @Binding var secondsText: String

    let canConfirm: Bool
    let onBack: () -> Void
    let onConfirm: () -> Void

    @FocusState private var focusedField: CountdownField?

    var body: some View {
        StudySessionPickerContainerView(
            canConfirm: canConfirm,
            onBack: onBack,
            onConfirm: onConfirm
        ) {
            HStack(spacing: .zero) {
                countdownField(
                    title: "Hora",
                    text: $hoursText,
                    field: .hours
                )

                colonView

                countdownField(
                    title: "Minuto",
                    text: $minutesText,
                    field: .minutes
                )

                colonView

                countdownField(
                    title: "Segundo",
                    text: $secondsText,
                    field: .seconds
                )
            }
            .padding(GlobalConfiguration.normalPadding)
            .background(AppColors.primaryLight)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.small)
                    .stroke(AppColors.neutralBlack, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
        }
        .onAppear {
            focusedField = .hours
        }
        .onChange(of: focusedField) { _, newValue in
            normalizeFields(excluding: newValue)
        }
    }
}

private extension StudySessionCountdownDurationPickerView {
    enum Layout {
        static let colonTopPadding: CGFloat = 30
        static let fieldSpacing: CGFloat = 12
        static let fieldFontSize: CGFloat = 68
        static let fieldWidth: CGFloat = 110
        static let fieldVerticalPadding: CGFloat = 10
        static let fieldCornerRadius: CGFloat = 4
        static let focusedFieldOpacity: CGFloat = 0.16
    }

    enum CountdownField: Hashable {
        case hours
        case minutes
        case seconds
    }

    var colonView: some View {
        Text(":")
            .font(.system(size: Layout.fieldFontSize, weight: .bold))
            .foregroundStyle(AppColors.neutralBlack)
            .padding(.top, Layout.colonTopPadding)
    }

    func countdownField(
        title: String,
        text: Binding<String>,
        field: CountdownField
    ) -> some View {
        VStack(spacing: Layout.fieldSpacing) {
            Text(title)
                .font(.title3)
                .foregroundStyle(AppColors.neutralBlack)

            TextField("00", text: text)
                .textFieldStyle(.plain)
                .font(.system(size: Layout.fieldFontSize, weight: .bold))
                .foregroundStyle(AppColors.neutralBlack)
                .multilineTextAlignment(.center)
                .frame(width: Layout.fieldWidth)
                .padding(.vertical, Layout.fieldVerticalPadding)
                .tint(AppColors.primary)
                .background(
                    RoundedRectangle(cornerRadius: Layout.fieldCornerRadius)
                        .fill(
                            focusedField == field
                            ? AppColors.primary.opacity(Layout.focusedFieldOpacity)
                            : .clear
                        )
                )
                .focused($focusedField, equals: field)
                .onTapGesture {
                    text.wrappedValue = ""
                    focusedField = field
                }
        }
    }

    func normalizeFields(excluding focusedField: CountdownField?) {
        normalizeField($hoursText, maximum: 99, ifNeededFor: .hours, excluding: focusedField)
        normalizeField($minutesText, maximum: 59, ifNeededFor: .minutes, excluding: focusedField)
        normalizeField($secondsText, maximum: 59, ifNeededFor: .seconds, excluding: focusedField)
    }

    func normalizeField(
        _ text: Binding<String>,
        maximum: Int,
        ifNeededFor field: CountdownField,
        excluding focusedField: CountdownField?
    ) {
        guard focusedField != field else { return }

        let digits = text.wrappedValue.filter(\.isNumber)
        let truncatedDigits = String(digits.prefix(2))

        guard !truncatedDigits.isEmpty else {
            text.wrappedValue = "00"
            return
        }

        let value = min(Int(truncatedDigits) ?? 0, maximum)
        text.wrappedValue = String(format: "%02d", value)
    }
}

#Preview {
    StudySessionCountdownDurationPickerView(
        hoursText: .constant("00"),
        minutesText: .constant("05"),
        secondsText: .constant("00"),
        canConfirm: true,
        onBack: {},
        onConfirm: {}
    )
    .frame(width: 600)
    .padding(40)
    .background(Color.gray.opacity(0.3))
}

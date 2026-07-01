//
//  StudySessionTimerScreenView.swift
//  Study
//

import SwiftUI

struct StudySessionTimerScreenView: View {

    let modeTitle: String
    let timerText: String
    let timerValue: Double
    let timerToggleSymbolName: String
    let onToggleTimer: () -> Void
    let onFinishStudySession: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: GlobalConfiguration.normalSpacing) {
            reservedAnimationArea

            VStack(spacing: GlobalConfiguration.normalSpacing) {
                Text(timerText)
                    .digitStyle(font: .largeTitle, value: timerValue)
                    .foregroundStyle(AppColors.neutralBlack)

                HStack(spacing: GlobalConfiguration.normalSpacing) {
                    TimerRoundButton(
                        backgroundColor: AppColors.neutralGray.opacity(0.25),
                        symbolName: timerToggleSymbolName,
                        symbolColor: AppColors.neutralBlack
                    ) {
                        onToggleTimer()
                    }

                    TimerRoundButton(
                        backgroundColor: AppColors.primary,
                        symbolName: "stop.fill",
                        symbolColor: AppColors.neutralWhite
                    ) {
                        onFinishStudySession()
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension StudySessionTimerScreenView {

    var reservedAnimationArea: some View {
        Rectangle()
            .stroke(AppColors.neutralBlack, lineWidth: 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StudySessionTimerScreenView(
        modeTitle: "Estudo com Cronômetro",
        timerText: "00:00:00",
        timerValue: 0,
        timerToggleSymbolName: "play.fill",
        onToggleTimer: {},
        onFinishStudySession: {}
    )
    .padding(40)
}

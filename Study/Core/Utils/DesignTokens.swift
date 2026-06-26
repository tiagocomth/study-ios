//
//  DesignTokens.swift
//  Study
//
//  Created by Breno Marques on 26/06/26.
//

import SwiftUI

enum AppColors {
    static let primary = Color.primaryPure
    static let primaryDisabled = Color.primaryPure.opacity(0.2)

    static let primaryLight = Color.primaryLight
    static let secondaryPure = Color.secondaryPure
    
    static let neutralWhite = Color.neutralColorwhite
    static let neutralBlack = Color.neutralColorblack
    static let neutralGray = Color.neutralColorgray
    
    static let studyColor = Color.studying
    static let notStudyingColor = Color.notStudying
}

enum AppRadius {
    static let small: CGFloat = 28
}

enum AppBorder {
    static let width: CGFloat = 2
}

enum AppShadow {
    static let radius: CGFloat = 4
    static let y: CGFloat = 3
}

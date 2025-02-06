//
//  AppInputConfig.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.12.2024.
//

import Foundation
import SwiftUI

enum InputSize: CGFloat {
    case M = 40.0
    case S = 32.0
}

struct AppInputConfig {
    enum UIElements {
        case border
        case text
        case placeholder
        case topHint
        case errorText
        case background
    }
    
    var defaultBorderColor: Color = .appBWVariants100700
    var focusedBorderColor: Color = .appOrange300
    var errorBorderColor: Color = .appRed300
    var disabledBorderColor: Color = .appBWVariants100700
    
    var textColor: Color = .appBWVariants950000
    
    var errorColor: Color = .appRed300
    
    var hintColor: Color = .appBlackWhite400
    
    var topHintColor: Color = .appBlackWhite400
    
    var defaultBackgroundColor: Color = .appBWVariants000900
    var disabledBackgroundColor: Color = .appBWVariants100700
    
    func getColorFor(_ element: UIElements, isError: Bool = false, isFocused: Bool = false, isDisabled: Bool = false) -> Color {
        switch (element) {
        case .border:
            return colorForBorder(isError: isError, isFocused: isFocused, isDisabled: isDisabled)
        case .text:
            return textColor
        case .placeholder:
            return hintColor
        case .topHint:
            return topHintColor
        case .errorText:
            return errorColor
        case .background:
            return isDisabled ? disabledBorderColor : defaultBackgroundColor
        }
    }
    
    private func colorForBorder(isError: Bool = false, isFocused: Bool = false, isDisabled: Bool = false) -> Color {
        if (isDisabled) {
            return disabledBorderColor
        } else if (isError) {
            return errorBorderColor
        } else if (isFocused) {
            return focusedBorderColor
        } else {
            return defaultBorderColor
        }
    }
}

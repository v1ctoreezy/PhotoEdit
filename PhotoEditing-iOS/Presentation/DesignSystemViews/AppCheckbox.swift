//
//  AppCheckbox.swift
//  UMobile
//
//  Created by Victor Cherkasov on 06.12.2024.
//

import SwiftUI

///
///  For custom implementation of Checkbox just replace default specified colors
///  This way: AppCheckboxConfig(defaultTextColor: .appOrange500) <- Now not disabled/default text color is Orange500
///
///  UIElements - enum of ui elements, needed to identify the element in order to get its regular or custom color
///
///  CheckboxState - controlls state of checkbox
///

struct AppCheckboxConfig {
    enum UIElements {
        case border
        case checkmark
        case background
        case text
    }
    
    enum CheckboxState {
        case `default`
        case disabled
    }
    
    var defaultCheckmarkColor: Color = .appBWVariants000900
    var selectedCheckmarkColor: Color = .appBWVariants000900
    var disabledSelectedCheckmarkColor: Color = .appBWVariants000900
    var disabledCheckmarkColor: Color = .appBWVariants050800
    
    var defaultBackgroundColor: Color = .appBWVariants000900
    var selectedBackgroundColor: Color = .appOrange500
    var disabledSelectedBackgroundColor: Color = .appBWVariants300600
    var disabledBackgroundColor: Color = .appBWVariants050800
    
    var defaultBorderColor: Color = .appBWVariants200400
    var selectedBorderColor: Color = .appOrange500
    var disabledSelectedBorderColor: Color = .appBWVariants300600
    var disabledBorderColor: Color = .appBWVariants200400
    
    var defaultTextColor: Color = .appBWVariants950000
    var disabledTextColor: Color = .appBWVariants300600
    
    func getColorFor(_ element: UIElements, _ isSelected: Bool, state: CheckboxState) -> Color {
        switch (element) {
        case .border:
            if (isSelected) {
                return state == .disabled ? disabledSelectedBorderColor : selectedBorderColor
            } else {
                return state == .disabled ? disabledBorderColor : defaultBorderColor
            }
        case .background:
            if (isSelected) {
                return state == .disabled ? disabledSelectedBackgroundColor : selectedBackgroundColor
            } else {
                return state == .disabled ? disabledBackgroundColor : defaultBackgroundColor
            }
        case .checkmark:
            if (isSelected) {
                return state == .disabled ? disabledSelectedCheckmarkColor : selectedCheckmarkColor
            } else {
                return state == .disabled ? disabledCheckmarkColor : defaultCheckmarkColor
            }
        case .text:
            return state == .disabled ? disabledTextColor : defaultTextColor
        }
    }
}

struct AppCheckbox: View {
    let title: String
    let isSelected: Bool
    var config: AppCheckboxConfig = AppCheckboxConfig()
    var state: AppCheckboxConfig.CheckboxState
    let action: CompletionBlock
    
    var body: some View {
        VStack {
            Button(action: {
                action()
            }, label: {
                HStack(spacing: 10) {
                    Text(title)
                        .foregroundColor(config.getColorFor(.text, isSelected, state: state))
                        .font(.app_M)
                        .multilineTextAlignment(.leading)
                    
                    checkmarkWithBox
                        .animation(.easeInOut, value: isSelected)
                }
            })
        }
        .disabled(state == .disabled)
    }
    
    var checkmarkWithBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(config.getColorFor(.background, isSelected, state: state))
                .frame(width: 20, height: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(config.getColorFor(.border, isSelected, state: state))
                )
            
            Img.Icons.Checkbox.checkmark
                .renderingMode(.template)
                .foregroundColor(config.getColorFor(.checkmark, isSelected, state: state))
        }
    }
}


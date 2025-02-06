//
//  AppSwitch.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.12.2024.
//

import SwiftUI

///
///  For custom implementation of AppSwitch just replace default specified colors
///  This way: AppSwitchConfig(defaultTextColor: .appOrange500) <- Now not disabled/default text color is Orange500
///
///  UIElements - enum of ui elements, needed to identify the element in order to get its regular or custom color
///
///  AppRadiobuttonState - controlls state of switch
///

struct AppSwitch: View {
    
    private let config: AppSwitchConfig = AppSwitchConfig()
    
    var title: String
    var isSelected: Binding<Bool>
    var state: AppSwitchConfig.AppSwitchState = .default
    
    var body: some View {
        VStack {
            Toggle(isOn: isSelected) {
                Text(title)
                    .foregroundColor(config.getColorFor(.text, isSelected.wrappedValue, state: state))
                    .font(.app_M)
            }
            .toggleStyle(
                UMobileSwitchStyle(
                    config: config,
                    state: state
                )
            )
        }
        .disabled(state == .disabled)
    }
}


struct AppSwitchConfig {
    fileprivate enum UIElements {
        case border
        case dot
        case background
        case text
    }
    
    enum AppSwitchState {
        case `default`
        case disabled
    }
    
    private var defaultDotColor: Color = .appBWVariants300600
    private var selectedDotColor: Color = .appBWVariants000900
    private var disabledSelectedDotColor: Color = .appBWVariants000900
    private var disabledDotColor: Color = .appBWVariants300600
    
    private var defaultBackgroundColor: Color = .appBWVariants000900
    private var selectedBackgroundColor: Color = .appOrange500
    private var disabledSelectedBackgroundColor: Color = .appBWVariants300600
    private var disabledBackgroundColor: Color = .appBWVariants100700
    
    private var defaultBorderColor: Color = .appBWVariants300600
    private var selectedBorderColor: Color = .appOrange500
    private var disabledSelectedBorderColor: Color = .appBWVariants300600
    private var disabledBorderColor: Color = .appBWVariants100700
    
    private var defaultTextColor: Color = .appBWVariants950000
    private var disabledTextColor: Color = .appBWVariants300600
    
    fileprivate func getColorFor(_ element: UIElements, _ isSelected: Bool, state: AppSwitchState) -> Color {
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
        case .dot:
            if (isSelected) {
                return state == .disabled ? disabledSelectedDotColor : selectedDotColor
            } else {
                return state == .disabled ? disabledDotColor : defaultDotColor
            }
        case .text:
            return state == .disabled ? disabledTextColor : defaultTextColor
        }
    }
}

private struct UMobileSwitchStyle: ToggleStyle {
    
    fileprivate var config: AppSwitchConfig = AppSwitchConfig()
    fileprivate var state: AppSwitchConfig.AppSwitchState
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            Rectangle()
                .foregroundColor(config.getColorFor(.border, configuration.isOn, state: state))
                .frame(width: 40, height: 24, alignment: .leading)
                .overlay(
                    Rectangle()
                        .fill(config.getColorFor(.background, configuration.isOn, state: state))
                        .foregroundColor(config.getColorFor(.border, configuration.isOn, state: state))
                        .frame(width: 38, height: 22, alignment: .leading)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                )
                .overlay(
                    Circle()
                        .foregroundColor(config.getColorFor(.dot, configuration.isOn, state: state))
                        .padding(.all, 4)
                        .offset(x: configuration.isOn ? 7 : -7, y: 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
        }
        .frame(alignment: .leading)
    }
}

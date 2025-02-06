//
//  AppRadiobutton.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.12.2024.
//

import SwiftUI

struct RadioButtonItem {
    let title: String
    let disabled: Bool = false
    var selected: Bool
}

private struct AppRadiobuttonConfig {
    enum UIElements {
        case border
        case dot
        case background
        case text
    }
    
    enum AppRadiobuttonState {
        case `default`
        case disabled
    }
    
    var defaultDotColor: Color = .appBWVariants000900
    var selectedDotColor: Color = .appBWVariants000900
    var disabledSelectedDotColor: Color = .appBWVariants000900
    var disabledDotColor: Color = .appBWVariants050800
    
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
    
    func getColorFor(_ element: UIElements, _ isSelected: Bool, state: AppRadiobuttonState) -> Color {
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

private struct AppRadiobutton: View {
    let title: String
    let isSelected: Bool
    var config: AppRadiobuttonConfig = AppRadiobuttonConfig()
    var state: AppRadiobuttonConfig.AppRadiobuttonState
    let action: (String) -> ()
    
    var body: some View {
        VStack {
            Button(action: {
                action(self.title)
            }, label: {
                HStack(spacing: 10) {
                    Text(title)
                        .foregroundColor(config.getColorFor(.text, isSelected, state: state))
                        .font(.app_M)
                        .multilineTextAlignment(.leading)
                    
                    Spacer().frame(minWidth: 8)
                    
                    circleWithDot
                        .animation(.easeInOut, value: isSelected)
                }
            })
        }
    }
    
    var circleWithDot: some View {
        Circle()
            .stroke(config.getColorFor(.border, isSelected, state: state))
            .background(config.getColorFor(.background, isSelected, state: state).cornerRadius(20))
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .fill(config.getColorFor(.dot, isSelected, state: state))
                    .frame(width: 8, height: 8)
            )
    }
}



struct RadioButtonGroup: View {
    
    @Binding var items : [RadioButtonItem]
    
    let callback: (String) -> ()
    
    var body: some View {
        VStack {
            ForEach(0..<items.count) { index in
                AppRadiobutton(title: self.items[index].title, isSelected: self.items[index].selected, state: state(self.items[index].disabled)) {_ in
                    self.radioGroupCallback(self.items[index])
                }
                .disabled(self.items[index].disabled)
            }
        }
    }
    
    func radioGroupCallback(_ item: RadioButtonItem) {
        for index in items.indices {
            items[index].selected = false
            if items[index].title == item.title {
                items[index].selected = true
            }
            callback(item.title)
            continue
        }
    }
    
    private func state(_ disabled: Bool) -> AppRadiobuttonConfig.AppRadiobuttonState {
        disabled ? .disabled : .default
    }
}



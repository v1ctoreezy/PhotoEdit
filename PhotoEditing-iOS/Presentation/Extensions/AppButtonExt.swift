//
//  AppButtonExt.swift
//  UMobile
//
//  Created by Good Shmorning on 09.12.2024.
//

import SwiftUI

extension AppButton {
    
    func setupColor(type: ButtonType, state: Bool, negative: Bool = false, disabled: Bool = false) -> Color {
        
        if disabled {
            return setupDisabledColor(type)
        } else if negative {
            return getNegativeColor(type, state)
        } else {
            return getColor(type, state)
        }
    }
    
    func setupCustomColor( _ state: Bool, colorButton: Color, pushColorButton: Color) -> Color {
        return state ? pushColorButton : colorButton
    }
    
    func setupColorIcon(_ type: ButtonType, _ state: Bool, negative: Bool = false, disabled: Bool = false) -> Color {
        
        if disabled {
            return getDisabledColorIcon(type)
        } else if negative {
            return getNegativeColorIcon(type, state)
        } else {
            return getColorIcon(type, state)
        }
    }
    
    func setupBorderIcon( _ state: Bool, negative: Bool, disabled: Bool, isLoading: Bool) -> Color {
        if disabled {
            return .appClear
        } else if isLoading {
            return .appClear
        } else if negative {
            return state ? .appRed400 : .appRed300
        } else {
            return state ? .appOrange500 : .appOrange500
        }
    }
    
    private func getDisabledColorIcon( _ type: ButtonType) -> Color {
        switch type {
        case .primary:
            return .appBWVariants300600
        case .secondary:
            return .appBWVariants300600
        case .ghost:
            return .appBWVariants300600
        case .clear:
            return .appBWVariants300600
        }
    }
    
    private func getNegativeColorIcon(_ type: ButtonType, _ state: Bool) -> Color {
        switch type {
        case .primary:
            return state ? .appBWVariants000900 : .appBWVariants000900
        case .secondary:
            return state ? .appRed400 : .appRed300
        case .ghost:
            return state ? .appRed400 : .appRed300
        case .clear:
            return state ? .appRed400 : .appRed300
        }
    }
    
    private func getColorIcon(_ type: ButtonType, _ state: Bool) -> Color {
        switch type {
        case .primary:
            return state ? .appBWVariants000900 : .appBWVariants000900
        case .secondary:
            return state ? .appOrange500 : .appOrange500
        case .ghost:
            return state ? .appOrange500 : .appOrange500
        case .clear:
            return state ? .appOrange500 : .appOrange500
        }
    }
    
    private func setupDisabledColor( _ type: ButtonType) -> Color {
        switch type {
        case .primary:
            return  .appBWVariants100700
        case .secondary:
            return  .appBWVariants100700
        case .ghost:
            return  .appBWVariants100700
        case .clear:
            return .appClear
        }
    }
    
    private func getNegativeColor(_ type: ButtonType, _ state: Bool) -> Color {
        switch type {
        case .primary:
            return state ? .appRed400 : .appRed300
        case .secondary:
            return state ? .appRed200 : .appClear
        case .ghost:
            return state ? .appRed100 : .appRed000
        case .clear:
            return state ? .appRed100: .appClear
        }
    }
    
    private func getColor(_ type: ButtonType, _ state: Bool) -> Color {
        switch type {
        case .primary:
            return state ? .appOrange600 : .appOrange500
        case .secondary:
            return state ? .appOrange200 : .appClear
        case .ghost:
            return state ? .appOrange000 : .appOrange100
        case .clear:
            return state ? .appOrange100: .appClear
        }
    }
    
}

extension AppButton {
    
    func getSpacing(_ size: ButtonSize) -> CGFloat {
        
        switch size {
        case .L:
            return 16
        case .M:
            return 12
        case .S:
            return 8
        case .XS:
            return 0
        }
    }
    
    func getHorizontalPadding(_ size: ButtonSize) -> CGFloat {
        
        switch size {
        case .L:
            return 20
        case .M:
            return 16
        case .S:
            return 12
        case .XS:
            return 12
        }
    }
    
    func getSizeImage(_ size: ButtonSize) -> CGFloat {
        
        switch size {
        case .L:
            return 24
        case .M:
            return 20
        case .S:
            return 16
        case .XS:
            return 0
        }
    }
    
    func getSizeLoader(_ size: ButtonSize) -> CGFloat {
        
        switch size {
        case .L:
            return 24
        case .M:
            return 24
        case .S:
            return 20
        case .XS:
            return 12
        }
    }
}

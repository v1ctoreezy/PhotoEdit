//
//  AppButton.swift
//  UMobile
//
//  Created by Good Shmorning on 27.11.2024.
//

import SwiftUI
import SDWebImageSwiftUI

enum ButtonType {
    case primary
    case secondary
    case ghost
    case clear
}

enum ButtonShape: CGFloat {
    case round = 24
    case square = 12
}

enum ButtonSetup {
    case simple(
        _ type: ButtonType,
        _ size: ButtonSize,
        _ shape: ButtonShape)
    
    case withIcons(
        _ type: ButtonType,
        _ size: ButtonSize,
        _ shape: ButtonShape,
        _ icons: ButtonIconType)
    
    case custom(
        _ size: ButtonSize,
        _ shape: ButtonShape,
        colorButton: Color,
        pushColorButton: Color,
        textColor: Color,
        _ icons: ButtonIconType?)
}

enum ButtonIconType {
    case icon(_ name₀: String?, _ name₁: String?)
    case image(_ url₀: String?, _ url₁: String?)
}

enum ButtonSize: CGFloat {
    case L = 48
    case M = 40
    case S = 32
    case XS = 24
}

struct AppButton: View {
    
    @State private var isPressed = false
    private let setup: ButtonSetup
    
    private let text: String?
    
    private let negative: Bool
    private let disabled: Bool
    private let isLoading: Bool
    private let customGesture: Bool
    
    let startedAction: CompletionBlock?
    let endedAction: CompletionBlock
    
    init(setup: ButtonSetup,
         text: String?,
         negative: Bool? = false,
         disabled: Bool,
         isLoading: Bool,
         customGesture: Bool = true,
         startedAction: CompletionBlock? = nil,
         endedAction: @escaping CompletionBlock
    ) {
        self.setup = setup
        self.text = text
        self.negative = negative ?? false
        self.disabled = disabled
        self.isLoading = isLoading
        self.customGesture = customGesture
        
        if let startedAction {
            self.startedAction = startedAction
        } else {
            self.startedAction = nil
        }
        self.endedAction = endedAction
    }
    
    var body: some View {
        
        if customGesture {
            customGestureButton()
                .gesture(_gesture)
                .onChange(of: isPressed) { _ in }
                .animation(.easeInOut, value: isPressed)
                .disabled(isLoading || disabled)
        } else {
            defaultGestureButton
                .disabled(isLoading || disabled)
        }
    }
    
    private var _gesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                setupStarterAction(); isPressed = true
            }
            .onEnded { _ in endedAction(); isPressed = false }
    }
    
    private func setupStarterAction() {
        guard !isPressed else { return }
        if let startedAction  {
            startedAction()
        }
    }
}


extension AppButton {
    
    var defaultGestureButton: some View {
        
        Button(action: endedAction) {
            EmptyView()
        }
        .buttonStyle(StateableButton(change: { state in
            ZStack {
                
                switch setup {
                case .simple(let type, let size, let shape):
                    
                    simpleButton(size: size)
                        .frame(height: size.rawValue)
                        .frame(minWidth: 320, maxWidth: .infinity)
                        .background(
                            setupColor(
                                type: type,
                                state: state,
                                negative: negative,
                                disabled: disabled
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: shape.rawValue))
                        .overlay(
                            RoundedRectangle(cornerRadius: shape.rawValue)
                                .strokeBorder(type == .secondary ? setupBorderIcon(state, negative: negative, disabled: disabled, isLoading: isLoading) : Color.clear, lineWidth: 1)
                        )
                        .disabled(isLoading || disabled)
                    
                case .withIcons(let type, let size, let shape, let icons):
                    
                    makeViewWithIcon(type: type, size: size, iconType: icons, state: state)
                        .frame(height: size.rawValue)
                        .frame(maxWidth: .infinity)
                        .background(
                            setupColor(
                                type: type,
                                state: state,
                                negative: negative,
                                disabled: disabled
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: shape.rawValue))
                        .overlay(
                            RoundedRectangle(cornerRadius: shape.rawValue)
                                .strokeBorder(type == .secondary ? setupBorderIcon(state, negative: negative, disabled: disabled, isLoading: isLoading) : Color.clear, lineWidth: 1)
                        )
                        .disabled(isLoading || disabled)
                    
                case .custom(let size, let shape, let color, let pushColor, let textColor, let icons):
                    customButton(size: size, iconType: icons, state: state)
                        .frame(height: size.rawValue)
                        .frame(maxWidth: .infinity)
                        .background(setupCustomColor(state, colorButton: color, pushColorButton: pushColor))
                        .clipShape(RoundedRectangle(cornerRadius: shape.rawValue))
                        .disabled(isLoading || disabled)
                }
            }
        }))
        .disabled(isLoading || disabled)
    }
}

extension AppButton {
    
    @ViewBuilder
    private func customGestureButton() -> some View {
        switch setup {
        case .simple(let type, let size, let shape):
            
            simpleButton(size: size)
                .frame(height: size.rawValue)
                .frame(minWidth: 320, maxWidth: .infinity)
                .background(
                    setupColor(
                        type: type,
                        state: isPressed,
                        negative: negative,
                        disabled: disabled
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: shape.rawValue))
                .overlay(
                    RoundedRectangle(cornerRadius: shape.rawValue)
                        .strokeBorder(type == .secondary ? setupBorderIcon(isPressed, negative: negative, disabled: disabled, isLoading: isLoading) : Color.clear, lineWidth: 1)
                )
                .disabled(isLoading || disabled)
            
        case .withIcons(let type, let size, let shape, let icons):
            
            makeViewWithIcon(type: type, size: size, iconType: icons, state: isPressed)
                .frame(height: size.rawValue)
                .frame(maxWidth: .infinity)
                .background(
                    setupColor(
                        type: type,
                        state: isPressed,
                        negative: negative,
                        disabled: disabled
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: shape.rawValue))
                .overlay(
                    RoundedRectangle(cornerRadius: shape.rawValue)
                        .strokeBorder(type == .secondary ? setupBorderIcon(isPressed, negative: negative, disabled: disabled, isLoading: isLoading) : Color.clear, lineWidth: 1)
                )
                .disabled(isLoading || disabled)
            
        case .custom(let size, let shape, let color, let pushColor, let textColor, let icons):
            customButton(size: size, iconType: icons, state: isPressed)
                .frame(height: size.rawValue)
                .frame(maxWidth: .infinity)
                .background(setupCustomColor(isPressed, colorButton: color, pushColorButton: pushColor))
                .clipShape(RoundedRectangle(cornerRadius: shape.rawValue))
                .disabled(isLoading || disabled)
        }
    }
}

extension AppButton {
    
    @ViewBuilder
    private func simpleButton(size: ButtonSize) -> some View {
        
        if self.isLoading {
            AppLoader(loaderGradient: (.appRed000, .appOrange200), isShowing: .constant(self.isLoading), width: getSizeLoader(size), height: getSizeLoader(size), lineWidth: 3)
        } else {
            textView()
        }
    }
    
    @ViewBuilder
    private func makeViewWithIcon(type: ButtonType, size: ButtonSize, iconType: ButtonIconType, state: Bool) -> some View {
        
        if self.isLoading {
            
            AppLoader(loaderGradient: (.appRed000, .appOrange200), isShowing: .constant(self.isLoading), width: getSizeLoader(size), height: getSizeLoader(size), lineWidth: 3)
            
        } else {
            
            switch iconType {
            case .icon(let name₀, let name₁):
                HStack(spacing: getSpacing(size)) {
                    if let icon = name₀ {
                        makeIcon(type: type, size: size, state: state, name: icon)
                    }
                    textView()
                    if let icon = name₁ {
                        makeIcon(type: type, size: size, state: state, name: icon)
                    }
                }
                .padding(.horizontal, getHorizontalPadding(size))
                
            case .image(let url₀, let url₁):
                HStack(spacing: getSpacing(size)) {
                    if let url = url₀ {
                        makeImage(size: size, state: state, url: url)
                    }
                    textView()
                    if let url = url₁ {
                        makeImage(size: size, state: state, url: url)
                    }
                }
                .padding(.horizontal, getHorizontalPadding(size))
            }
            
        }
    }
    
    @ViewBuilder
    private func textView() -> some View {
        if let text = text {
            Text(text)
        }
    }
    
    private func makeIcon(type: ButtonType, size: ButtonSize, state: Bool, name: String) -> some View {
        Image(name)
            .renderingMode(.template)
            .frame(width: getSizeImage(size), height: getSizeImage(size))
            .foregroundColor(setupColorIcon(type, state, negative: negative, disabled: disabled))
    }
    
    private func makeImage(size: ButtonSize, state: Bool, url: String) -> some View {
        WebImage(url: URL(string: url))
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: getSizeImage(size), height: getSizeImage(size))
    }
    
}

extension AppButton {
    
    @ViewBuilder
    private func customButton(size: ButtonSize, iconType: ButtonIconType?, state: Bool) -> some View {
        
        if self.isLoading {
            
            AppLoader(loaderGradient: (.appRed000, .appOrange200), isShowing: .constant(self.isLoading), width: getSizeLoader(size), height: getSizeLoader(size), lineWidth: 3)
            
        } else {
            
            switch iconType {
            case .icon(let name₀, let name₁):
                HStack(spacing: getSpacing(size)) {
                    if let icon = name₀ {
                        Image(icon)
                            .renderingMode(.template)
                            .frame(width: getSizeImage(size), height: getSizeImage(size))
                    }
                    textView()
                    if let icon = name₁ {
                        Image(icon)
                            .renderingMode(.template)
                            .frame(width: getSizeImage(size), height: getSizeImage(size))
                    }
                }
                .padding(.horizontal, getHorizontalPadding(size))
                
            case .image(let url₀, let url₁):
                HStack(spacing: getSpacing(size)) {
                    if let url = url₀ {
                        makeImage(size: size, state: state, url: url)
                    }
                    textView()
                    if let url = url₁ {
                        makeImage(size: size, state: state, url: url)
                    }
                }
                .padding(.horizontal, getHorizontalPadding(size))
            case .none:
                textView()
            }
        }
    }
}



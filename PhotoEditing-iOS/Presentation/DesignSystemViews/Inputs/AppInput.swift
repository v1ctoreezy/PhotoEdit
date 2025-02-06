//
//  AppInput.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.12.2024.
//

import SwiftUI

struct AppInput: View {
    @Binding var stringText: String
    @Binding var errorMessage: String
    
    @State private var isFocused: Bool = false
    @Binding var isError: Bool
    var isDisabled: Bool = false
    
    let placeholder: String
    var height: CGFloat
    var topHintText: String
    var keyboardType: UIKeyboardType = .default
    
    var config: AppInputConfig
    
    init(
        placeholder: String,
        height: InputSize = InputSize.M,
        stringText: Binding<String>,
        topHintText: String = "",
        errorMessage: Binding<String> = .constant(""),
        keyboardType: UIKeyboardType = .default,
        config: AppInputConfig = AppInputConfig(),
        isError: Binding<Bool>,
        isDisabled: Bool
    ) {
        self.placeholder = placeholder
        self.height = height.rawValue
        self._stringText = stringText
        self.topHintText = topHintText
        self._errorMessage = errorMessage
        self.keyboardType = keyboardType
        self.config = config
        self._isError = isError
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            hintText
            
            ZStack(alignment: .center) {
                TextField("", text: $stringText, onEditingChanged: { _isFocused in
                    withAnimation(.easeOut(duration: 0.2)) {
                        isFocused = _isFocused
                    }
                })
                .modifier(
                    PlaceholderStyle(showPlaceHolder: stringText.isEmpty, placeholder: placeholder)
                )
                .keyboardType(keyboardType)
                .font(.app_M)
                .foregroundColor(.appBWVariants950000)
                .frame(height: height)
                .padding(.horizontal, 16)
                .padding(.trailing, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(lineWidth: 1)
                        .foregroundColor(
                            config.getColorFor(
                                .border,
                                isError: isError,
                                isFocused: isFocused,
                                isDisabled: isDisabled
                            )
                        )
                        .background(
                            config.getColorFor(
                                .background,
                                isError: isError,
                                isFocused: isFocused,
                                isDisabled: isDisabled
                            )
                        )
                        .cornerRadius(12)
                )
                .disabled(isDisabled)
                .padding(.vertical, 4)
                
                Img.Icons.DsIcons.icCross
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.appBlackWhite400)
                    .frame(width: 16, height: 16)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 12)
                    .isHidden(stringText.isEmpty)
                    .animation(.easeInOut, value: stringText.isEmpty)
                    .transition(
                        .opacity.animation(.easeInOut)
                    )
                    .padding(.top, 2)
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        stringText = ""
                    }))
            }
            
            errorText
                .onChange(of: stringText, perform: { _ in
                    isError = false
                    errorMessage = ""
                })
        }
    }
    
    var hintText: some View {
        ZStack {
            Text(placeholder)
                .font(.app_S)
                .foregroundColor(.appBlackWhite400)
                .isHidden(stringText.isEmpty || topHintText.isEmpty)
                .animation(.easeInOut, value: stringText.isEmpty)
                .transition(
                    .opacity.animation(.easeInOut)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 16)
        .frame(height: 18)
    }
    
    var errorText: some View {
        ZStack {
            Text(errorMessage)
                .font(.app_S)
                .foregroundColor(.appRed300)
                .isHidden(errorMessage.isEmpty)
                .animation(.easeInOut, value: errorMessage.isEmpty)
                .transition(
                    .opacity.animation(.easeInOut)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 16)
        .frame(height: 18)
    }
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            Text(placeholder)
                .font(.app_M)
                .foregroundColor(.appBlackWhite400)
                .isHidden(!showPlaceHolder)
                .animation(.easeInOut(duration: 0.5), value: showPlaceHolder)
                .transition(
                    .asymmetric(
                        insertion: .opacity,
                        removal: .identity
                    )
                )
            content
                .foregroundColor(.appBWVariants950000)
        }
    }
}

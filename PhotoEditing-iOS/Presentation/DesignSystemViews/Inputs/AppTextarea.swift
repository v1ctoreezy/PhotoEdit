//
//  AppTextarea.swift
//  UMobile
//
//  Created by Victor Cherkasov on 09.12.2024.
//

import SwiftUI

struct AppTextarea: View {
        
    let placeholder: String
    let limit: Int
    
    var config: AppInputConfig = AppInputConfig()
    @Binding var errorMessage: String
    
    @State private var isFocused: Bool = false
    @Binding var isError: Bool
    var isDisabled: Bool = false
    var size: CGSize
        
    @Binding var stringText: String
    
    init(placeholder: String, limit: Int, errorMessage: Binding<String>, isError: Binding<Bool>, isDisabled: Bool, stringText: Binding<String>, size: CGSize = .init(width: 320, height: 178)) {
        self.placeholder = placeholder
        self.limit = limit
        self._errorMessage = errorMessage
        self._isError = isError
        self.isDisabled = isDisabled
        self._stringText = stringText
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 0) {
            WrappedTextArea(text: $stringText, isFocused: $isFocused, placeholder: placeholder)
                .onChange(of: stringText) { newValue in
                    if newValue.count > limit {
                        self.stringText = String(newValue.prefix(limit))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
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
                .zIndex(0)
                .disabled(isDisabled)
            
            errorText
                .padding(.top, 4)
        }
        .frame(height: size.height + 18)
    }
    
    var errorText: some View {
        ZStack {
            Text(LocalStrings.typeFill)
                .font(.app_M)
                .foregroundColor(
                    config.getColorFor(
                        .errorText,
                        isError: isError,
                        isFocused: isFocused,
                        isDisabled: isDisabled
                    )
                )
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .isHidden(errorMessage.isEmpty)
                .onChange(of: stringText, perform: { _ in
                    isError = false
                    errorMessage = ""
                })
        }
        .frame(height: 18)
        .padding(.leading, 18)
    }
}

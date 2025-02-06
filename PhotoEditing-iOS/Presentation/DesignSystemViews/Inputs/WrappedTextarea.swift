//
//  WrappedTextArea.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 13.12.2024.
//

import SwiftUI

struct WrappedTextArea: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    
    var placeholder: String 
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.appFont(size: 16, weight: .regular)
        label.textColor = UIColor(.appBlackWhite400)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .appFont(size: 16, weight: .regular)
        
        textView.addSubview(placeholderLabel)
        textView.backgroundColor = .clear
        
        placeholderLabel.text = placeholder
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: (textView.font?.pointSize ?? 2) / 2),
            placeholderLabel.widthAnchor.constraint(equalTo: textView.widthAnchor, multiplier: 1)
        ])
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isFocused: $isFocused, label: placeholderLabel)
    }
}

extension WrappedTextArea {
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool
        
        var label: UILabel
        
        init(
            text: Binding<String>,
            isFocused: Binding<Bool>,
            label: UILabel
        ) {
            self._text = text
            self._isFocused = isFocused
            self.label = label
        }
        
        func textViewDidChangeSelection(_ textField: UITextView) {
            text = textField.text ?? ""
        }
        
        func textViewDidChange(_ textView: UITextView) {
            label.alpha = textView.text.isEmpty ? 1 : 0
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            isFocused = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            isFocused = false
        }
    }
}

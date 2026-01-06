import SwiftUI

// MARK: - Text Edit Tab Enum

enum TextEditTab {
    case color
    case font
    case style
}

struct TextMenuView: View {
    
    @EnvironmentObject var shared: PhotoEditingController
    @State private var inputText: String = ""
    @State private var showingInput: Bool = false
    @State private var selectedTab: TextEditTab = .color
    
    private var selectedText: TextElement? {
        guard let selectedId = shared.textCtrl.selectedTextId else { return nil }
        return shared.textCtrl.textElements.first { $0.id == selectedId }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                if showingInput {
                    textInputSection
                } else if selectedText != nil {
                    textEditingSection
                }
                
                if !shared.textCtrl.textElements.isEmpty {
                    textListSection
                        .padding(.top, 8)
                }
                
                addTextButton
                    .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Add Text Button
    
    private var addTextButton: some View {
        Button(action: {
            showingInput = true
            inputText = "Текст"
        }) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue)
                .cornerRadius(22)
        }
    }
    
    // MARK: - Text Input Section
    
    private var textInputSection: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Введите текст", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                
                Button("Добавить") {
                    if !inputText.isEmpty {
                        shared.textCtrl.addText(inputText)
                        inputText = ""
                        showingInput = false
                    }
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                
                Button("Отмена") {
                    showingInput = false
                    inputText = ""
                }
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Text Editing Section
    
    private var textEditingSection: some View {
        guard let text = selectedText else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(spacing: 8) {
                // Tab Selector
                tabSelector
                
                // Tab Content
                tabContent(for: text)
            }
        )
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(
                icon: "paintpalette.fill",
                title: "Цвет",
                isSelected: selectedTab == .color,
                action: { selectedTab = .color }
            )
            
            TabButton(
                icon: "textformat.size",
                title: "Шрифт",
                isSelected: selectedTab == .font,
                action: { selectedTab = .font }
            )
            
            TabButton(
                icon: "bold.italic.underline",
                title: "Стиль",
                isSelected: selectedTab == .style,
                action: { selectedTab = .style }
            )
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private func tabContent(for text: TextElement) -> some View {
        switch selectedTab {
        case .color:
            colorPaletteSection(for: text)
                .padding(.vertical, 8)
        case .font:
            VStack(spacing: 16) {
                fontSizeSection(for: text)
                Divider()
                fontSelectionSection(for: text)
            }
            .padding(.vertical, 8)
        case .style:
            styleButtonsSection(for: text)
                .padding(.vertical, 8)
        }
    }
    
    // MARK: - Color Palette Section
    
    private func colorPaletteSection(for text: TextElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Цвет")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ColorButton(color: .white, isSelected: text.color == .white) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .white)
                    }
                    ColorButton(color: .black, isSelected: text.color == .black) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .black)
                    }
                    ColorButton(color: .red, isSelected: text.color == .red) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .red)
                    }
                    ColorButton(color: .blue, isSelected: text.color == .blue) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .blue)
                    }
                    ColorButton(color: .green, isSelected: text.color == .green) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .green)
                    }
                    ColorButton(color: .yellow, isSelected: text.color == .yellow) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .yellow)
                    }
                    ColorButton(color: .orange, isSelected: text.color == .orange) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .orange)
                    }
                    ColorButton(color: .purple, isSelected: text.color == .purple) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .purple)
                    }
                    ColorButton(color: .pink, isSelected: text.color == .pink) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .pink)
                    }
                    ColorButton(color: .gray, isSelected: text.color == .gray) {
                        shared.textCtrl.updateColor(id: text.id, newColor: .gray)
                    }
                }
            }
        }
    }
    
    // MARK: - Font Size Section
    
    private func fontSizeSection(for text: TextElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Размер")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(text.fontSize))")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Slider(
                value: Binding(
                    get: { text.fontSize },
                    set: { shared.textCtrl.updateFontSize(id: text.id, newSize: $0) }
                ),
                in: 12...72,
                step: 1
            )
            .accentColor(.blue)
        }
    }
    
    // MARK: - Font Selection Section
    
    private func fontSelectionSection(for text: TextElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Шрифт")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FontButton(fontName: "System", displayName: "Системный", isSelected: text.fontName == "System") {
                        shared.textCtrl.updateFontName(id: text.id, newFontName: "System")
                    }
                    FontButton(fontName: "Helvetica", displayName: "Helvetica", isSelected: text.fontName == "Helvetica") {
                        shared.textCtrl.updateFontName(id: text.id, newFontName: "Helvetica")
                    }
                    FontButton(fontName: "Arial", displayName: "Arial", isSelected: text.fontName == "Arial") {
                        shared.textCtrl.updateFontName(id: text.id, newFontName: "Arial")
                    }
                    FontButton(fontName: "Courier", displayName: "Courier", isSelected: text.fontName == "Courier") {
                        shared.textCtrl.updateFontName(id: text.id, newFontName: "Courier")
                    }
                    FontButton(fontName: "Georgia", displayName: "Georgia", isSelected: text.fontName == "Georgia") {
                        shared.textCtrl.updateFontName(id: text.id, newFontName: "Georgia")
                    }
                    FontButton(fontName: "Times New Roman", displayName: "Times", isSelected: text.fontName == "Times New Roman") {
                        shared.textCtrl.updateFontName(id: text.id, newFontName: "Times New Roman")
                    }
                    FontButton(fontName: "Verdana", displayName: "Verdana", isSelected: text.fontName == "Verdana") {
                        shared.textCtrl.updateFontName(id: text.id, newFontName: "Verdana")
                    }
                }
            }
        }
    }
    
    // MARK: - Style Buttons Section
    
    private func styleButtonsSection(for text: TextElement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Стиль")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                StyleButton(
                    icon: "bold",
                    isActive: text.isBold,
                    action: {
                        shared.textCtrl.toggleBold(id: text.id)
                    }
                )
                
                StyleButton(
                    icon: "italic",
                    isActive: text.isItalic,
                    action: {
                        shared.textCtrl.toggleItalic(id: text.id)
                    }
                )
                
                Spacer()
            }
        }
    }
    
    // MARK: - Text List Section
    
    private var textListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Тексты")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(shared.textCtrl.textElements) { textElement in
                        TextElementCard(
                            textElement: textElement,
                            isSelected: shared.textCtrl.selectedTextId == textElement.id,
                            onSelect: {
                                shared.textCtrl.selectText(id: textElement.id)
                            },
                            onDelete: {
                                shared.textCtrl.deleteText(id: textElement.id)
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 11))
            }
            .foregroundColor(isSelected ? .blue : .white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            .cornerRadius(8)
        }
    }
}

// MARK: - Color Button

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 1)
                )
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
                        .padding(-2)
                )
        }
    }
}

// MARK: - Font Button

struct FontButton: View {
    let fontName: String
    let displayName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(displayName)
                .font(.custom(fontName == "System" ? "System" : fontName, size: 14))
                .foregroundColor(isSelected ? .blue : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
    }
}

// MARK: - Style Button

struct StyleButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .blue : .white)
                .frame(width: 44, height: 44)
                .background(isActive ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
    }
}

// MARK: - Text Element Card

struct TextElementCard: View {
    let textElement: TextElement
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text(textElement.text)
                .font(.system(size: 14))
                .foregroundColor(textElement.color)
                .lineLimit(2)
                .frame(width: 80, height: 40)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
    }
}


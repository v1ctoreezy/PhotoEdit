import Foundation
import SwiftUI
import Combine

class TextController: ObservableObject {
    
    @Published var textElements: [TextElement] = []
    @Published var selectedTextId: UUID?
    @Published var isAddingText: Bool = false
    
    // Add new text element at center
    func addText(_ text: String = "Текст") {
        let newElement = TextElement(
            text: text,
            position: CGPoint(x: 0.5, y: 0.5), // Normalized coordinates (0-1)
            color: .white,
            fontSize: 24
        )
        textElements.append(newElement)
        selectedTextId = newElement.id
    }
    
    // Update text content
    func updateText(id: UUID, newText: String) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].text = newText
        }
    }
    
    // Update text position
    func updatePosition(id: UUID, newPosition: CGPoint) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].position = newPosition
        }
    }
    
    // Update text color
    func updateColor(id: UUID, newColor: Color) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].color = newColor
        }
    }
    
    // Update font size
    func updateFontSize(id: UUID, newSize: CGFloat) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].fontSize = newSize
        }
    }
    
    // Update font name
    func updateFontName(id: UUID, newFontName: String) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].fontName = newFontName
        }
    }
    
    // Toggle bold
    func toggleBold(id: UUID) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].isBold.toggle()
        }
    }
    
    // Toggle italic
    func toggleItalic(id: UUID) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].isItalic.toggle()
        }
    }
    
    // Delete text element
    func deleteText(id: UUID) {
        textElements.removeAll { $0.id == id }
        if selectedTextId == id {
            selectedTextId = nil
        }
    }
    
    // Clear all texts
    func clearAll() {
        textElements.removeAll()
        selectedTextId = nil
    }
    
    // Select text
    func selectText(id: UUID?) {
        selectedTextId = id
    }
}


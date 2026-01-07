import Foundation
import SwiftUI
import Combine

class TextController: ObservableObject {
    
    @Published var textElements: [TextElement] = []
    @Published var selectedTextId: UUID?
    @Published var isAddingText: Bool = false
    
    // Reference to EditOperationManager
    weak var operationManager: EditOperationManager?
    
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
        
        // Add text operation to the stack using the element's conversion method
        addTextOperationToStack(for: newElement)
    }
    
    // Update text content
    func updateText(id: UUID, newText: String) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].text = newText
            addTextOperationToStack(for: textElements[index])
        }
    }
    
    // Update text position
    func updatePosition(id: UUID, newPosition: CGPoint) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].position = newPosition
            addTextOperationToStack(for: textElements[index])
        }
    }
    
    // Update text color
    func updateColor(id: UUID, newColor: Color) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].color = newColor
            addTextOperationToStack(for: textElements[index])
        }
    }
    
    // Update font size
    func updateFontSize(id: UUID, newSize: CGFloat) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].fontSize = newSize
            addTextOperationToStack(for: textElements[index])
        }
    }
    
    // Update font name
    func updateFontName(id: UUID, newFontName: String) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].fontName = newFontName
            addTextOperationToStack(for: textElements[index])
        }
    }
    
    // Toggle bold
    func toggleBold(id: UUID) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].isBold.toggle()
            addTextOperationToStack(for: textElements[index])
        }
    }
    
    // Toggle italic
    func toggleItalic(id: UUID) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].isItalic.toggle()
            addTextOperationToStack(for: textElements[index])
        }
    }
    
    // Delete text element
    func deleteText(id: UUID) {
        textElements.removeAll { $0.id == id }
        if selectedTextId == id {
            selectedTextId = nil
        }
        // Note: deletion is handled by removing text operation from the stack
        // The operation manager will handle undo/redo
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
    
    // MARK: - Operation Stack Integration
    
    /// Helper method to add text operation to the stack
    private func addTextOperationToStack(for element: TextElement) {
        let textOp = element.toTextOperation()
        operationManager?.addOperation(textOp)
    }
    
    /// Apply operations from the operation manager
    /// This should be called when the operation stack changes (undo/redo)
    func syncWithOperationStack() {
        guard let activeOps = operationManager?.getActiveOperations() else { return }
        
        // Get all text operations
        let textOps = activeOps.filter { $0.type == .text }
        
        // Rebuild text elements from operations
        var newElements: [TextElement] = []
        var elementById: [UUID: TextElement] = [:]
        
        for anyOp in textOps {
            guard let textOp = anyOp.asTextOperation() else { continue }
            
            // Check if we already have an element with this ID
            if let existingElement = elementById[textOp.textElementId] {
                // Update existing element with latest operation data
                var updated = existingElement
                updated.text = textOp.text
                updated.position = textOp.position
                updated.fontSize = textOp.fontSize
                updated.fontName = textOp.fontName
                updated.color = textOp.color.color
                updated.isBold = textOp.isBold
                updated.isItalic = textOp.isItalic
                elementById[textOp.textElementId] = updated
            } else {
                // Create new element from operation
                let element = TextElement.from(textOperation: textOp)
                elementById[textOp.textElementId] = element
            }
        }
        
        // Convert to array, maintaining the order of operations
        newElements = textOps.compactMap { anyOp -> TextElement? in
            guard let textOp = anyOp.asTextOperation() else { return nil }
            return elementById[textOp.textElementId]
        }
        
        // Remove duplicates (keep the last occurrence of each element)
        var seenIds = Set<UUID>()
        textElements = newElements.reversed().filter { element in
            if seenIds.contains(element.id) {
                return false
            }
            seenIds.insert(element.id)
            return true
        }.reversed()
    }
    
    /// Call this when undo is triggered from the main controller
    func handleUndo() {
        syncWithOperationStack()
    }
    
    /// Call this when redo is triggered from the main controller
    func handleRedo() {
        syncWithOperationStack()
    }
}


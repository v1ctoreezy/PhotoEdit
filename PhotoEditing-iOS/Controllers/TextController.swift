import Foundation
import SwiftUI
import Combine

class TextController: ObservableObject {
    
    @Published var textElements: [TextElement] = []
    @Published var selectedTextId: UUID?
    @Published var isAddingText: Bool = false
    weak var operationManager: EditOperationManager?

    func addText(_ text: String = "Текст") {
        let newElement = TextElement(
            text: text,
            position: CGPoint(x: 0.5, y: 0.5),
            color: .white,
            fontSize: 24
        )
        textElements.append(newElement)
        selectedTextId = newElement.id
        addTextOperationToStack(for: newElement)
    }

    func updateText(id: UUID, newText: String) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].text = newText
            addTextOperationToStack(for: textElements[index])
        }
    }

    func updatePosition(id: UUID, newPosition: CGPoint) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].position = newPosition
            addTextOperationToStack(for: textElements[index])
        }
    }

    func updateColor(id: UUID, newColor: Color) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].color = newColor
            addTextOperationToStack(for: textElements[index])
        }
    }

    func updateFontSize(id: UUID, newSize: CGFloat) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].fontSize = newSize
            addTextOperationToStack(for: textElements[index])
        }
    }

    func updateFontName(id: UUID, newFontName: String) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].fontName = newFontName
            addTextOperationToStack(for: textElements[index])
        }
    }

    func toggleBold(id: UUID) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].isBold.toggle()
            addTextOperationToStack(for: textElements[index])
        }
    }

    func toggleItalic(id: UUID) {
        if let index = textElements.firstIndex(where: { $0.id == id }) {
            textElements[index].isItalic.toggle()
            addTextOperationToStack(for: textElements[index])
        }
    }

    func deleteText(id: UUID) {
        textElements.removeAll { $0.id == id }
        if selectedTextId == id {
            selectedTextId = nil
        }
    }

    func clearAll() {
        textElements.removeAll()
        selectedTextId = nil
    }

    func selectText(id: UUID?) {
        selectedTextId = id
    }

    private func addTextOperationToStack(for element: TextElement) {
        let textOp = element.toTextOperation()
        operationManager?.addOperation(textOp)
    }

    func syncWithOperationStack() {
        guard let activeOps = operationManager?.getActiveOperations() else { return }
        let textOps = activeOps.filter { $0.type == .text }
        var newElements: [TextElement] = []
        var elementById: [UUID: TextElement] = [:]
        
        for anyOp in textOps {
            guard let textOp = anyOp.asTextOperation() else { continue }
            if let existingElement = elementById[textOp.textElementId] {
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
                let element = TextElement.from(textOperation: textOp)
                elementById[textOp.textElementId] = element
            }
        }
        newElements = textOps.compactMap { anyOp -> TextElement? in
            guard let textOp = anyOp.asTextOperation() else { return nil }
            return elementById[textOp.textElementId]
        }
        var seenIds = Set<UUID>()
        textElements = newElements.reversed().filter { element in
            if seenIds.contains(element.id) {
                return false
            }
            seenIds.insert(element.id)
            return true
        }.reversed()
    }

    func handleUndo() {
        syncWithOperationStack()
    }

    func handleRedo() {
        syncWithOperationStack()
    }
}


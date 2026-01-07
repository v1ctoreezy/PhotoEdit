import Foundation
import SwiftUI
import CoreImage

// MARK: - EditOperationManager Extensions

extension EditOperationManager {
    
    /// Add a text operation from a TextElement
    func addTextOperation(from element: TextElement) {
        let textOp = element.toTextOperation()
        addOperation(textOp)
    }
    
    /// Get all text operations
    func getTextOperations() -> [TextOperation] {
        return getOperations(ofType: .text).compactMap { $0.asTextOperation() }
    }
    
    /// Get all active text operations
    func getActiveTextOperations() -> [TextOperation] {
        return getActiveOperations().filter { $0.type == .text }.compactMap { $0.asTextOperation() }
    }
    
    /// Remove text operation by text element ID
    func removeTextOperation(forElementId elementId: UUID) {
        let textOps = getTextOperations()
        if let op = textOps.first(where: { $0.textElementId == elementId }) {
            removeOperation(id: op.id)
        }
    }
    
    /// Check if there are any text operations
    var hasTextOperations: Bool {
        return getOperations(ofType: .text).isEmpty == false
    }
}

// MARK: - TextController Extensions

extension TextController {
    
    /// Get text elements from the operation manager
    func syncTextElementsFromOperations() {
        syncWithOperationStack()
    }
    
    /// Add text with operation tracking
    func addTextWithTracking(_ text: String = "Текст", at position: CGPoint? = nil) {
        let pos = position ?? CGPoint(x: 0.5, y: 0.5)
        let newElement = TextElement(
            text: text,
            position: pos,
            color: .white,
            fontSize: 24
        )
        textElements.append(newElement)
        selectedTextId = newElement.id
        
        // Add to operation stack
        operationManager?.addTextOperation(from: newElement)
    }
    
    /// Update text and track in operations
    func updateTextWithTracking(id: UUID, newText: String) {
        updateText(id: id, newText: newText)
    }
    
    /// Update position and track in operations
    func updatePositionWithTracking(id: UUID, newPosition: CGPoint) {
        updatePosition(id: id, newPosition: newPosition)
    }
    
    /// Delete text and remove from operation stack
    func deleteTextWithTracking(id: UUID) {
        deleteText(id: id)
        operationManager?.removeTextOperation(forElementId: id)
    }
}

// MARK: - Helper Methods

extension EditOperationManager {
    
    /// Apply all operations and get the result image
    func applyAllOperations(to image: CIImage) -> CIImage {
        var result = image
        for op in getActiveOperations() {
            result = op.apply(to: result)
        }
        return result
    }
    
    /// Get a summary of all operations
    func getOperationsSummary() -> String {
        let stats = getStatistics()
        var summary = "Всего операций: \(stats.totalOperations)\n"
        summary += "Активных операций: \(stats.activeOperations)\n"
        summary += "По типам:\n"
        
        for (type, count) in stats.operationsByType.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            summary += "  - \(type.displayName): \(count)\n"
        }
        
        return summary
    }
}

// MARK: - EditOperationType Display Names

extension EditOperationType {
    var displayName: String {
        switch self {
        case .filter:
            return "Фильтр"
        case .text:
            return "Текст"
        case .sticker:
            return "Стикер"
        case .drawing:
            return "Рисунок"
        case .adjustment:
            return "Коррекция"
        case .blur:
            return "Размытие"
        case .crop:
            return "Обрезка"
        case .rotate:
            return "Поворот"
        case .flip:
            return "Отражение"
        case .custom:
            return "Пользовательская"
        }
    }
}

// MARK: - Batch Operations

extension EditOperationManager {
    
    /// Apply multiple operations at once
    func addOperations<T: EditOperation>(_ operations: [T]) {
        for operation in operations {
            addOperation(operation)
        }
    }
    
    /// Undo multiple operations
    func undo(count: Int) {
        for _ in 0..<count where canUndo {
            undo()
        }
    }
    
    /// Redo multiple operations
    func redo(count: Int) {
        for _ in 0..<count where canRedo {
            redo()
        }
    }
}


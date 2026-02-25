import Foundation
import SwiftUI
import CoreImage

extension EditOperationManager {
    func addTextOperation(from element: TextElement) {
        let textOp = element.toTextOperation()
        addOperation(textOp)
    }

    func getTextOperations() -> [TextOperation] {
        return getOperations(ofType: .text).compactMap { $0.asTextOperation() }
    }

    func getActiveTextOperations() -> [TextOperation] {
        return getActiveOperations().filter { $0.type == .text }.compactMap { $0.asTextOperation() }
    }

    func removeTextOperation(forElementId elementId: UUID) {
        let textOps = getTextOperations()
        if let op = textOps.first(where: { $0.textElementId == elementId }) {
            removeOperation(id: op.id)
        }
    }

    var hasTextOperations: Bool {
        return getOperations(ofType: .text).isEmpty == false
    }
}

extension TextController {
    func syncTextElementsFromOperations() {
        syncWithOperationStack()
    }

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
        operationManager?.addTextOperation(from: newElement)
    }

    func updateTextWithTracking(id: UUID, newText: String) {
        updateText(id: id, newText: newText)
    }

    func updatePositionWithTracking(id: UUID, newPosition: CGPoint) {
        updatePosition(id: id, newPosition: newPosition)
    }

    func deleteTextWithTracking(id: UUID) {
        deleteText(id: id)
        operationManager?.removeTextOperation(forElementId: id)
    }
}

extension EditOperationManager {
    func applyAllOperations(to image: CIImage) -> CIImage {
        var result = image
        for op in getActiveOperations() {
            result = op.apply(to: result)
        }
        return result
    }

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

extension EditOperationType {
    var displayName: String {
        switch self {
        case .filter: return "Фильтр"
        case .text: return "Текст"
        case .sticker: return "Стикер"
        case .drawing: return "Рисунок"
        case .adjustment: return "Коррекция"
        case .blur: return "Размытие"
        case .crop: return "Обрезка"
        case .rotate: return "Поворот"
        case .flip: return "Отражение"
        case .custom: return "Пользовательская"
        }
    }
}

extension EditOperationManager {
    func addOperations<T: EditOperation>(_ operations: [T]) {
        for operation in operations {
            addOperation(operation)
        }
    }

    func undo(count: Int) {
        for _ in 0..<count where canUndo {
            undo()
        }
    }

    func redo(count: Int) {
        for _ in 0..<count where canRedo {
            redo()
        }
    }
}

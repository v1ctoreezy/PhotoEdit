import Foundation
import SwiftUI
import Combine
import CoreImage
import PixelEnginePackage

/// Менеджер для управления стеком операций редактирования
public class EditOperationManager: ObservableObject {
    
    // MARK: - Properties
    
    /// Стек всех операций
    @Published private(set) var operations: [AnyEditOperation] = []
    
    /// Индекс текущей операции (для undo/redo)
    @Published private(set) var currentIndex: Int = -1
    
    /// Оригинальное изображение
    private var originalImage: CIImage?
    
    /// Текущий EditingStack (для фильтров PixelEngine)
    var editingStack: EditingStack?
    
    // MARK: - Computed Properties
    
    var canUndo: Bool {
        return currentIndex >= 0
    }
    
    var canRedo: Bool {
        return currentIndex < operations.count - 1
    }
    
    var hasOperations: Bool {
        return !operations.isEmpty
    }
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Установить оригинальное изображение
    public func setOriginalImage(_ image: CIImage) {
        self.originalImage = image
        self.operations.removeAll()
        self.currentIndex = -1
    }
    
    /// Добавить новую операцию
    public func addOperation<T: EditOperation>(_ operation: T) {
        // Удаляем все операции после текущего индекса (для redo)
        if currentIndex < operations.count - 1 {
            operations.removeSubrange((currentIndex + 1)...)
        }
        
        // Добавляем новую операцию
        let anyOperation = AnyEditOperation(operation)
        operations.append(anyOperation)
        currentIndex = operations.count - 1
        
        objectWillChange.send()
    }
    
    /// Отменить последнюю операцию
    public func undo() {
        guard canUndo else { return }
        currentIndex -= 1
        objectWillChange.send()
    }
    
    /// Повторить операцию
    public func redo() {
        guard canRedo else { return }
        currentIndex += 1
        objectWillChange.send()
    }
    
    /// Очистить все операции
    public func clear() {
        operations.removeAll()
        currentIndex = -1
        objectWillChange.send()
    }
    
    /// Удалить конкретную операцию
    public func removeOperation(at index: Int) {
        guard index >= 0 && index < operations.count else { return }
        operations.remove(at: index)
        if currentIndex >= index {
            currentIndex = max(-1, currentIndex - 1)
        }
        objectWillChange.send()
    }
    
    /// Удалить операцию по ID
    public func removeOperation(id: UUID) {
        if let index = operations.firstIndex(where: { $0.id == id }) {
            removeOperation(at: index)
        }
    }
    
    /// Получить текущее обработанное изображение
    public func getCurrentImage() -> CIImage? {
        guard let original = originalImage else { return nil }
        guard currentIndex >= 0 else { return original }
        
        // Применяем все операции до текущего индекса
        var result = original
        for i in 0...currentIndex where i < operations.count {
            result = operations[i].apply(to: result)
        }
        
        return result
    }
    
    /// Получить список активных операций (до текущего индекса)
    public func getActiveOperations() -> [AnyEditOperation] {
        guard currentIndex >= 0 else { return [] }
        return Array(operations[0...currentIndex])
    }
    
    /// Получить операции определенного типа
    public func getOperations(ofType type: EditOperationType) -> [AnyEditOperation] {
        return operations.filter { $0.type == type }
    }
    
    /// Экспорт операций (для сохранения рецептов)
    public func exportOperations() -> Foundation.Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(getActiveOperations())
    }
    
    /// Импорт операций (загрузка рецептов)
    public func importOperations(from data: Foundation.Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let imported = try decoder.decode([AnyEditOperation].self, from: data)
        
        self.operations = imported
        self.currentIndex = imported.count - 1
        objectWillChange.send()
    }
    
    /// Создать снимок текущего состояния
    public func createSnapshot() -> EditOperationSnapshot {
        return EditOperationSnapshot(
            operations: getActiveOperations(),
            currentIndex: currentIndex
        )
    }
    
    /// Восстановить состояние из снимка
    public func restore(from snapshot: EditOperationSnapshot) {
        self.operations = snapshot.operations
        self.currentIndex = snapshot.currentIndex
        objectWillChange.send()
    }
}

// MARK: - Type-Erased Wrapper

/// Обёртка для type-erasure протокола EditOperation
public struct AnyEditOperation: EditOperation, Codable {
    public let id: UUID
    public let type: EditOperationType
    public let timestamp: Date
    public var description: String
    public var isReversible: Bool
    
    private let _apply: (CIImage) -> CIImage
    private let baseOperation: Any
    
    public init<T: EditOperation>(_ operation: T) {
        self.id = operation.id
        self.type = operation.type
        self.timestamp = operation.timestamp
        self.description = operation.description
        self.isReversible = operation.isReversible
        self._apply = operation.apply
        self.baseOperation = operation
    }
    
    public func apply(to image: CIImage) -> CIImage {
        return _apply(image)
    }
    
    // MARK: - Base Operation Access
    
    /// Get the underlying TextOperation if this is a text operation
    public func asTextOperation() -> TextOperation? {
        return baseOperation as? TextOperation
    }
    
    /// Get the underlying FilterOperation if this is a filter operation
    public func asFilterOperation() -> FilterOperation? {
        return baseOperation as? FilterOperation
    }
    
    /// Get the underlying StickerOperation if this is a sticker operation
    public func asStickerOperation() -> StickerOperation? {
        return baseOperation as? StickerOperation
    }
    
    /// Get the underlying AdjustmentOperation if this is an adjustment operation
    public func asAdjustmentOperation() -> AdjustmentOperation? {
        return baseOperation as? AdjustmentOperation
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, type, timestamp, operationData
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        
        // Кодируем конкретную операцию в зависимости от типа
        switch type {
        case .filter:
            if let op = baseOperation as? FilterOperation {
                try container.encode(op, forKey: .operationData)
            }
        case .text:
            if let op = baseOperation as? TextOperation {
                try container.encode(op, forKey: .operationData)
            }
        case .sticker:
            if let op = baseOperation as? StickerOperation {
                try container.encode(op, forKey: .operationData)
            }
        case .adjustment:
            if let op = baseOperation as? AdjustmentOperation {
                try container.encode(op, forKey: .operationData)
            }
        default:
            break
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(EditOperationType.self, forKey: .type)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        // Декодируем конкретную операцию в зависимости от типа
        switch type {
        case .filter:
            let op = try container.decode(FilterOperation.self, forKey: .operationData)
            self.baseOperation = op
            self._apply = op.apply
            self.description = op.description
            self.isReversible = op.isReversible
            
        case .text:
            let op = try container.decode(TextOperation.self, forKey: .operationData)
            self.baseOperation = op
            self._apply = op.apply
            self.description = op.description
            self.isReversible = op.isReversible
            
        case .sticker:
            let op = try container.decode(StickerOperation.self, forKey: .operationData)
            self.baseOperation = op
            self._apply = op.apply
            self.description = op.description
            self.isReversible = op.isReversible
            
        case .adjustment:
            let op = try container.decode(AdjustmentOperation.self, forKey: .operationData)
            self.baseOperation = op
            self._apply = op.apply
            self.description = op.description
            self.isReversible = op.isReversible
            
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported operation type"
            )
        }
    }
}

// MARK: - Snapshot

/// Снимок состояния операций (для undo/redo на уровне выше)
public struct EditOperationSnapshot {
    public let operations: [AnyEditOperation]
    public let currentIndex: Int
}

// MARK: - Extensions

extension EditOperationManager {
    /// Получить статистику по операциям
    public func getStatistics() -> OperationStatistics {
        let byType = Dictionary(grouping: operations, by: { $0.type })
        let counts = byType.mapValues { $0.count }
        
        return OperationStatistics(
            totalOperations: operations.count,
            activeOperations: currentIndex + 1,
            operationsByType: counts
        )
    }
}

public struct OperationStatistics {
    public let totalOperations: Int
    public let activeOperations: Int
    public let operationsByType: [EditOperationType: Int]
}


import Foundation
import SwiftUI
import Combine
import CoreImage
import PixelEnginePackage

public class EditOperationManager: ObservableObject {

    @Published private(set) var operations: [AnyEditOperation] = []
    @Published private(set) var currentIndex: Int = -1
    private var originalImage: CIImage?
    var editingStack: EditingStack?

    var canUndo: Bool {
        return currentIndex >= 0
    }

    var canRedo: Bool {
        return currentIndex < operations.count - 1
    }

    var hasOperations: Bool {
        return !operations.isEmpty
    }

    public init() {}

    public func setOriginalImage(_ image: CIImage) {
        self.originalImage = image
        self.operations.removeAll()
        self.currentIndex = -1
    }

    public func addOperation<T: EditOperation>(_ operation: T) {
        if currentIndex < operations.count - 1 {
            operations.removeSubrange((currentIndex + 1)...)
        }
        let anyOperation = AnyEditOperation(operation)
        operations.append(anyOperation)
        currentIndex = operations.count - 1
        objectWillChange.send()
    }

    public func undo() {
        guard canUndo else { return }
        currentIndex -= 1
        objectWillChange.send()
    }

    public func redo() {
        guard canRedo else { return }
        currentIndex += 1
        objectWillChange.send()
    }

    public func clear() {
        operations.removeAll()
        currentIndex = -1
        objectWillChange.send()
    }

    public func removeOperation(at index: Int) {
        guard index >= 0 && index < operations.count else { return }
        operations.remove(at: index)
        if currentIndex >= index {
            currentIndex = max(-1, currentIndex - 1)
        }
        objectWillChange.send()
    }

    public func removeOperation(id: UUID) {
        if let index = operations.firstIndex(where: { $0.id == id }) {
            removeOperation(at: index)
        }
    }

    public func getCurrentImage() -> CIImage? {
        guard let original = originalImage else { return nil }
        guard currentIndex >= 0 else { return original }
        var result = original
        for i in 0...currentIndex where i < operations.count {
            result = operations[i].apply(to: result)
        }
        return result
    }

    public func getActiveOperations() -> [AnyEditOperation] {
        guard currentIndex >= 0 else { return [] }
        return Array(operations[0...currentIndex])
    }

    public func getOperations(ofType type: EditOperationType) -> [AnyEditOperation] {
        return operations.filter { $0.type == type }
    }

    public func exportOperations() -> Foundation.Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(getActiveOperations())
    }

    public func importOperations(from data: Foundation.Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let imported = try decoder.decode([AnyEditOperation].self, from: data)
        self.operations = imported
        self.currentIndex = imported.count - 1
        objectWillChange.send()
    }

    public func createSnapshot() -> EditOperationSnapshot {
        return EditOperationSnapshot(
            operations: getActiveOperations(),
            currentIndex: currentIndex
        )
    }

    public func restore(from snapshot: EditOperationSnapshot) {
        self.operations = snapshot.operations
        self.currentIndex = snapshot.currentIndex
        objectWillChange.send()
    }
}

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

    public func asTextOperation() -> TextOperation? {
        return baseOperation as? TextOperation
    }

    public func asFilterOperation() -> FilterOperation? {
        return baseOperation as? FilterOperation
    }

    public func asStickerOperation() -> StickerOperation? {
        return baseOperation as? StickerOperation
    }

    public func asAdjustmentOperation() -> AdjustmentOperation? {
        return baseOperation as? AdjustmentOperation
    }

    enum CodingKeys: String, CodingKey {
        case id, type, timestamp, operationData
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
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

public struct EditOperationSnapshot {
    public let operations: [AnyEditOperation]
    public let currentIndex: Int
}

extension EditOperationManager {
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

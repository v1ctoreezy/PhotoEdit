import XCTest
import CoreImage
import SwiftUI
import PixelEnginePackage
@testable import PhotoEditing_iOS

/// Unit тесты для EditOperationManager
class EditOperationManagerTests: XCTestCase {
    
    var editOperationManager: EditOperationManager!
    var testImage: CIImage!
    
    override func setUp() {
        super.setUp()
        editOperationManager = EditOperationManager()
        
        // Создаём тестовое изображение 100x100
        let size = CGSize(width: 100, height: 100)
        let rect = CGRect(origin: .zero, size: size)
        testImage = CIImage(color: CIColor(red: 1, green: 0, blue: 0))
            .cropped(to: rect)
    }
    
    override func tearDown() {
        editOperationManager = nil
        testImage = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given & When
        let manager = EditOperationManager()
        
        // Then
        XCTAssertEqual(manager.operations.count, 0, "Should start with empty operations")
        XCTAssertEqual(manager.currentIndex, -1, "Current index should be -1")
        XCTAssertFalse(manager.canUndo, "Should not be able to undo")
        XCTAssertFalse(manager.canRedo, "Should not be able to redo")
        XCTAssertFalse(manager.hasOperations, "Should have no operations")
    }
    
    // MARK: - Set Original Image Tests
    
    func testSetOriginalImage() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        
        // When
        editOperationManager.setOriginalImage(testImage)
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 0, "Should clear operations")
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Should reset index")
    }
    
    // MARK: - Add Operation Tests
    
    func testAddOperation() {
        // Given
        let operation = createTestFilterOperation()
        
        // When
        editOperationManager.addOperation(operation)
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 1, "Should have one operation")
        XCTAssertEqual(editOperationManager.currentIndex, 0, "Current index should be 0")
        XCTAssertTrue(editOperationManager.canUndo, "Should be able to undo")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
        XCTAssertTrue(editOperationManager.hasOperations, "Should have operations")
    }
    
    func testAddMultipleOperations() {
        // Given & When
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 3, "Should have three operations")
        XCTAssertEqual(editOperationManager.currentIndex, 2, "Current index should be 2")
    }
    
    func testAddOperationAfterUndo_ShouldClearRedoStack() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        editOperationManager.undo()
        editOperationManager.undo()
        
        // When - добавляем новую операцию после undo
        editOperationManager.addOperation(createTestFilterOperation(name: "NewFilter"))
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 2, "Should have two operations (first + new)")
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be 1")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    // MARK: - Undo Tests
    
    func testUndo() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        // When
        editOperationManager.undo()
        
        // Then
        XCTAssertEqual(editOperationManager.currentIndex, 0, "Current index should be 0")
        XCTAssertTrue(editOperationManager.canUndo, "Should still be able to undo")
        XCTAssertTrue(editOperationManager.canRedo, "Should be able to redo")
    }
    
    func testUndoMultipleTimes() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        
        // When
        editOperationManager.undo()
        editOperationManager.undo()
        editOperationManager.undo()
        
        // Then
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Current index should be -1")
        XCTAssertFalse(editOperationManager.canUndo, "Should not be able to undo")
        XCTAssertTrue(editOperationManager.canRedo, "Should be able to redo")
    }
    
    func testUndoWhenEmpty_ShouldNotCrash() {
        // Given - пустой менеджер
        
        // When & Then
        editOperationManager.undo()
        
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Index should remain -1")
        XCTAssertFalse(editOperationManager.canUndo, "Should not be able to undo")
    }
    
    // MARK: - Redo Tests
    
    func testRedo() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.undo()
        
        // When
        editOperationManager.redo()
        
        // Then
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be 1")
        XCTAssertTrue(editOperationManager.canUndo, "Should be able to undo")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    func testRedoMultipleTimes() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.undo()
        editOperationManager.undo()
        
        // When
        editOperationManager.redo()
        editOperationManager.redo()
        
        // Then
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be 1")
        XCTAssertTrue(editOperationManager.canUndo, "Should be able to undo")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    func testRedoWhenAtEnd_ShouldNotCrash() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        
        // When & Then
        editOperationManager.redo()
        
        XCTAssertEqual(editOperationManager.currentIndex, 0, "Index should remain at end")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    // MARK: - Clear Tests
    
    func testClear() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        // When
        editOperationManager.clear()
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 0, "Should have no operations")
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Index should be -1")
        XCTAssertFalse(editOperationManager.canUndo, "Should not be able to undo")
        XCTAssertFalse(editOperationManager.hasOperations, "Should have no operations")
    }
    
    // MARK: - Remove Operation Tests
    
    func testRemoveOperationAtIndex() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        
        // When
        editOperationManager.removeOperation(at: 1)
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 2, "Should have two operations")
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be adjusted")
    }
    
    func testRemoveOperationAtInvalidIndex_ShouldNotCrash() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        
        // When & Then
        editOperationManager.removeOperation(at: 10)
        editOperationManager.removeOperation(at: -1)
        
        XCTAssertEqual(editOperationManager.operations.count, 1, "Should still have one operation")
    }
    
    func testRemoveOperationById() {
        // Given
        let op1 = createTestFilterOperation(name: "Filter1")
        let op2 = createTestFilterOperation(name: "Filter2")
        editOperationManager.addOperation(op1)
        editOperationManager.addOperation(op2)
        
        // When
        editOperationManager.removeOperation(id: op1.id)
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 1, "Should have one operation")
        XCTAssertEqual(editOperationManager.operations[0].id, op2.id, "Remaining operation should be op2")
    }
    
    // MARK: - Get Current Image Tests
    
    func testGetCurrentImage_WithNoImage() {
        // When
        let result = editOperationManager.getCurrentImage()
        
        // Then
        XCTAssertNil(result, "Should return nil when no original image")
    }
    
    func testGetCurrentImage_WithNoOperations() {
        // Given
        editOperationManager.setOriginalImage(testImage)
        
        // When
        let result = editOperationManager.getCurrentImage()
        
        // Then
        XCTAssertNotNil(result, "Should return image")
        XCTAssertEqual(result?.extent, testImage.extent, "Should return original image")
    }
    
    // MARK: - Get Active Operations Tests
    
    func testGetActiveOperations() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        
        // When
        let active = editOperationManager.getActiveOperations()
        
        // Then
        XCTAssertEqual(active.count, 3, "Should have three active operations")
    }
    
    func testGetActiveOperations_AfterUndo() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        editOperationManager.undo()
        
        // When
        let active = editOperationManager.getActiveOperations()
        
        // Then
        XCTAssertEqual(active.count, 2, "Should have two active operations")
    }
    
    func testGetActiveOperations_WhenEmpty() {
        // When
        let active = editOperationManager.getActiveOperations()
        
        // Then
        XCTAssertEqual(active.count, 0, "Should have no active operations")
    }
    
    // MARK: - Get Operations By Type Tests
    
    func testGetOperationsByType() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestTextOperation())
        
        // When
        let filters = editOperationManager.getOperations(ofType: .filter)
        let adjustments = editOperationManager.getOperations(ofType: .adjustment)
        let texts = editOperationManager.getOperations(ofType: .text)
        
        // Then
        XCTAssertEqual(filters.count, 2, "Should have two filter operations")
        XCTAssertEqual(adjustments.count, 1, "Should have one adjustment operation")
        XCTAssertEqual(texts.count, 1, "Should have one text operation")
    }
    
    // MARK: - Export/Import Tests
    
    func testExportOperations() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        // When
        let data = editOperationManager.exportOperations()
        
        // Then
        XCTAssertNotNil(data, "Should export data")
        XCTAssertGreaterThan(data?.count ?? 0, 0, "Exported data should not be empty")
    }
    
    func testImportOperations() throws {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        let exportedData = editOperationManager.exportOperations()!
        
        let newManager = EditOperationManager()
        
        // When
        try newManager.importOperations(from: exportedData)
        
        // Then
        XCTAssertEqual(newManager.operations.count, 2, "Should import two operations")
        XCTAssertEqual(newManager.currentIndex, 1, "Current index should be 1")
    }
    
    func testExportImportRoundTrip() throws {
        // Given
        let filter = createTestFilterOperation(name: "TestFilter")
        let adjustment = createTestAdjustmentOperation(type: .exposure, value: 0.5)
        let text = createTestTextOperation(text: "Test Text")
        
        editOperationManager.addOperation(filter)
        editOperationManager.addOperation(adjustment)
        editOperationManager.addOperation(text)
        
        // When
        let data = editOperationManager.exportOperations()!
        let newManager = EditOperationManager()
        try newManager.importOperations(from: data)
        
        // Then
        XCTAssertEqual(newManager.operations.count, 3, "Should import all operations")
        XCTAssertEqual(newManager.operations[0].type, .filter, "First should be filter")
        XCTAssertEqual(newManager.operations[1].type, .adjustment, "Second should be adjustment")
        XCTAssertEqual(newManager.operations[2].type, .text, "Third should be text")
    }
    
    // MARK: - Snapshot Tests
    
    func testCreateSnapshot() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        // When
        let snapshot = editOperationManager.createSnapshot()
        
        // Then
        XCTAssertEqual(snapshot.operations.count, 2, "Snapshot should have two operations")
        XCTAssertEqual(snapshot.currentIndex, 1, "Snapshot index should be 1")
    }
    
    func testRestoreFromSnapshot() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        let snapshot = editOperationManager.createSnapshot()
        
        editOperationManager.clear()
        
        // When
        editOperationManager.restore(from: snapshot)
        
        // Then
        XCTAssertEqual(editOperationManager.operations.count, 2, "Should restore two operations")
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Should restore index")
    }
    
    func testSnapshotAfterUndo() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.addOperation(createTestTextOperation())
        editOperationManager.undo()
        
        // When
        let snapshot = editOperationManager.createSnapshot()
        
        // Then
        XCTAssertEqual(snapshot.operations.count, 2, "Snapshot should have two active operations")
    }
    
    // MARK: - Statistics Tests
    
    func testGetStatistics() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.addOperation(createTestTextOperation())
        
        // When
        let stats = editOperationManager.getStatistics()
        
        // Then
        XCTAssertEqual(stats.totalOperations, 4, "Should have four total operations")
        XCTAssertEqual(stats.activeOperations, 4, "Should have four active operations")
        XCTAssertEqual(stats.operationsByType[.filter], 2, "Should have two filters")
        XCTAssertEqual(stats.operationsByType[.adjustment], 1, "Should have one adjustment")
        XCTAssertEqual(stats.operationsByType[.text], 1, "Should have one text")
    }
    
    func testGetStatistics_AfterUndo() {
        // Given
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.undo()
        
        // When
        let stats = editOperationManager.getStatistics()
        
        // Then
        XCTAssertEqual(stats.totalOperations, 2, "Should have two total operations")
        XCTAssertEqual(stats.activeOperations, 1, "Should have one active operation")
    }
    
    // MARK: - Helper Methods
    
    private func createTestFilterOperation(name: String = "TestFilter") -> FilterOperation {
        return FilterOperation(
            filterName: name,
            lutIdentifier: "test_lut",
            intensity: 1.0,
            parameters: ["exposure": 0.5, "contrast": 0.3]
        )
    }
    
    private func createTestAdjustmentOperation(type: AdjustmentType = .exposure, value: Double = 0.5) -> AdjustmentOperation {
        return AdjustmentOperation(adjustmentType: type, value: value)
    }
    
    private func createTestTextOperation(text: String = "Test") -> TextOperation {
        return TextOperation(
            text: text,
            position: CGPoint(x: 100, y: 100),
            fontSize: 24,
            color: .white
        )
    }
}

import XCTest
import CoreImage
import SwiftUI
import PixelEnginePackage
@testable import PhotoEditing_iOS

class EditOperationManagerTests: XCTestCase {
    
    var editOperationManager: EditOperationManager!
    var testImage: CIImage!
    
    override func setUp() {
        super.setUp()
        editOperationManager = EditOperationManager()
        
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
    
    
    func testInitialization() {
        let manager = EditOperationManager()
        
        XCTAssertEqual(manager.operations.count, 0, "Should start with empty operations")
        XCTAssertEqual(manager.currentIndex, -1, "Current index should be -1")
        XCTAssertFalse(manager.canUndo, "Should not be able to undo")
        XCTAssertFalse(manager.canRedo, "Should not be able to redo")
        XCTAssertFalse(manager.hasOperations, "Should have no operations")
    }
    
    
    func testSetOriginalImage() {
        editOperationManager.addOperation(createTestFilterOperation())
        
        editOperationManager.setOriginalImage(testImage)
        
        XCTAssertEqual(editOperationManager.operations.count, 0, "Should clear operations")
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Should reset index")
    }
    
    
    func testAddOperation() {
        let operation = createTestFilterOperation()
        
        editOperationManager.addOperation(operation)
        
        XCTAssertEqual(editOperationManager.operations.count, 1, "Should have one operation")
        XCTAssertEqual(editOperationManager.currentIndex, 0, "Current index should be 0")
        XCTAssertTrue(editOperationManager.canUndo, "Should be able to undo")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
        XCTAssertTrue(editOperationManager.hasOperations, "Should have operations")
    }
    
    func testAddMultipleOperations() {
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        XCTAssertEqual(editOperationManager.operations.count, 3, "Should have three operations")
        XCTAssertEqual(editOperationManager.currentIndex, 2, "Current index should be 2")
    }
    
    func testAddOperationAfterUndo_ShouldClearRedoStack() {
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        editOperationManager.undo()
        editOperationManager.undo()
        
        editOperationManager.addOperation(createTestFilterOperation(name: "NewFilter"))
        
        XCTAssertEqual(editOperationManager.operations.count, 2, "Should have two operations (first + new)")
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be 1")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    
    func testUndo() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        editOperationManager.undo()
        
        XCTAssertEqual(editOperationManager.currentIndex, 0, "Current index should be 0")
        XCTAssertTrue(editOperationManager.canUndo, "Should still be able to undo")
        XCTAssertTrue(editOperationManager.canRedo, "Should be able to redo")
    }
    
    func testUndoMultipleTimes() {
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        
        editOperationManager.undo()
        editOperationManager.undo()
        editOperationManager.undo()
        
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Current index should be -1")
        XCTAssertFalse(editOperationManager.canUndo, "Should not be able to undo")
        XCTAssertTrue(editOperationManager.canRedo, "Should be able to redo")
    }
    
    func testUndoWhenEmpty_ShouldNotCrash() {
        
        editOperationManager.undo()
        
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Index should remain -1")
        XCTAssertFalse(editOperationManager.canUndo, "Should not be able to undo")
    }
    
    
    func testRedo() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.undo()
        
        editOperationManager.redo()
        
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be 1")
        XCTAssertTrue(editOperationManager.canUndo, "Should be able to undo")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    func testRedoMultipleTimes() {
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.undo()
        editOperationManager.undo()
        
        editOperationManager.redo()
        editOperationManager.redo()
        
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be 1")
        XCTAssertTrue(editOperationManager.canUndo, "Should be able to undo")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    func testRedoWhenAtEnd_ShouldNotCrash() {
        editOperationManager.addOperation(createTestFilterOperation())
        
        editOperationManager.redo()
        
        XCTAssertEqual(editOperationManager.currentIndex, 0, "Index should remain at end")
        XCTAssertFalse(editOperationManager.canRedo, "Should not be able to redo")
    }
    
    
    func testClear() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        editOperationManager.clear()
        
        XCTAssertEqual(editOperationManager.operations.count, 0, "Should have no operations")
        XCTAssertEqual(editOperationManager.currentIndex, -1, "Index should be -1")
        XCTAssertFalse(editOperationManager.canUndo, "Should not be able to undo")
        XCTAssertFalse(editOperationManager.hasOperations, "Should have no operations")
    }
    
    
    func testRemoveOperationAtIndex() {
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        
        editOperationManager.removeOperation(at: 1)
        
        XCTAssertEqual(editOperationManager.operations.count, 2, "Should have two operations")
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Current index should be adjusted")
    }
    
    func testRemoveOperationAtInvalidIndex_ShouldNotCrash() {
        editOperationManager.addOperation(createTestFilterOperation())
        
        editOperationManager.removeOperation(at: 10)
        editOperationManager.removeOperation(at: -1)
        
        XCTAssertEqual(editOperationManager.operations.count, 1, "Should still have one operation")
    }
    
    func testRemoveOperationById() {
        let op1 = createTestFilterOperation(name: "Filter1")
        let op2 = createTestFilterOperation(name: "Filter2")
        editOperationManager.addOperation(op1)
        editOperationManager.addOperation(op2)
        
        editOperationManager.removeOperation(id: op1.id)
        
        XCTAssertEqual(editOperationManager.operations.count, 1, "Should have one operation")
        XCTAssertEqual(editOperationManager.operations[0].id, op2.id, "Remaining operation should be op2")
    }
    
    
    func testGetCurrentImage_WithNoImage() {
        let result = editOperationManager.getCurrentImage()
        
        XCTAssertNil(result, "Should return nil when no original image")
    }
    
    func testGetCurrentImage_WithNoOperations() {
        editOperationManager.setOriginalImage(testImage)
        
        let result = editOperationManager.getCurrentImage()
        
        XCTAssertNotNil(result, "Should return image")
        XCTAssertEqual(result?.extent, testImage.extent, "Should return original image")
    }
    
    
    func testGetActiveOperations() {
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        
        let active = editOperationManager.getActiveOperations()
        
        XCTAssertEqual(active.count, 3, "Should have three active operations")
    }
    
    func testGetActiveOperations_AfterUndo() {
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter1"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter2"))
        editOperationManager.addOperation(createTestFilterOperation(name: "Filter3"))
        editOperationManager.undo()
        
        let active = editOperationManager.getActiveOperations()
        
        XCTAssertEqual(active.count, 2, "Should have two active operations")
    }
    
    func testGetActiveOperations_WhenEmpty() {
        let active = editOperationManager.getActiveOperations()
        
        XCTAssertEqual(active.count, 0, "Should have no active operations")
    }
    
    
    func testGetOperationsByType() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestTextOperation())
        
        let filters = editOperationManager.getOperations(ofType: .filter)
        let adjustments = editOperationManager.getOperations(ofType: .adjustment)
        let texts = editOperationManager.getOperations(ofType: .text)
        
        XCTAssertEqual(filters.count, 2, "Should have two filter operations")
        XCTAssertEqual(adjustments.count, 1, "Should have one adjustment operation")
        XCTAssertEqual(texts.count, 1, "Should have one text operation")
    }
    
    
    func testExportOperations() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        let data = editOperationManager.exportOperations()
        
        XCTAssertNotNil(data, "Should export data")
        XCTAssertGreaterThan(data?.count ?? 0, 0, "Exported data should not be empty")
    }
    
    func testImportOperations() throws {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        let exportedData = editOperationManager.exportOperations()!
        
        let newManager = EditOperationManager()
        
        try newManager.importOperations(from: exportedData)
        
        XCTAssertEqual(newManager.operations.count, 2, "Should import two operations")
        XCTAssertEqual(newManager.currentIndex, 1, "Current index should be 1")
    }
    
    func testExportImportRoundTrip() throws {
        let filter = createTestFilterOperation(name: "TestFilter")
        let adjustment = createTestAdjustmentOperation(type: .exposure, value: 0.5)
        let text = createTestTextOperation(text: "Test Text")
        
        editOperationManager.addOperation(filter)
        editOperationManager.addOperation(adjustment)
        editOperationManager.addOperation(text)
        
        let data = editOperationManager.exportOperations()!
        let newManager = EditOperationManager()
        try newManager.importOperations(from: data)
        
        XCTAssertEqual(newManager.operations.count, 3, "Should import all operations")
        XCTAssertEqual(newManager.operations[0].type, .filter, "First should be filter")
        XCTAssertEqual(newManager.operations[1].type, .adjustment, "Second should be adjustment")
        XCTAssertEqual(newManager.operations[2].type, .text, "Third should be text")
    }
    
    
    func testCreateSnapshot() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        
        let snapshot = editOperationManager.createSnapshot()
        
        XCTAssertEqual(snapshot.operations.count, 2, "Snapshot should have two operations")
        XCTAssertEqual(snapshot.currentIndex, 1, "Snapshot index should be 1")
    }
    
    func testRestoreFromSnapshot() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        let snapshot = editOperationManager.createSnapshot()
        
        editOperationManager.clear()
        
        editOperationManager.restore(from: snapshot)
        
        XCTAssertEqual(editOperationManager.operations.count, 2, "Should restore two operations")
        XCTAssertEqual(editOperationManager.currentIndex, 1, "Should restore index")
    }
    
    func testSnapshotAfterUndo() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.addOperation(createTestTextOperation())
        editOperationManager.undo()
        
        let snapshot = editOperationManager.createSnapshot()
        
        XCTAssertEqual(snapshot.operations.count, 2, "Snapshot should have two active operations")
    }
    
    
    func testGetStatistics() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.addOperation(createTestTextOperation())
        
        let stats = editOperationManager.getStatistics()
        
        XCTAssertEqual(stats.totalOperations, 4, "Should have four total operations")
        XCTAssertEqual(stats.activeOperations, 4, "Should have four active operations")
        XCTAssertEqual(stats.operationsByType[.filter], 2, "Should have two filters")
        XCTAssertEqual(stats.operationsByType[.adjustment], 1, "Should have one adjustment")
        XCTAssertEqual(stats.operationsByType[.text], 1, "Should have one text")
    }
    
    func testGetStatistics_AfterUndo() {
        editOperationManager.addOperation(createTestFilterOperation())
        editOperationManager.addOperation(createTestAdjustmentOperation())
        editOperationManager.undo()
        
        let stats = editOperationManager.getStatistics()
        
        XCTAssertEqual(stats.totalOperations, 2, "Should have two total operations")
        XCTAssertEqual(stats.activeOperations, 1, "Should have one active operation")
    }
    
    
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

import XCTest
import CoreImage
import SwiftUI
import PixelEnginePackage
@testable import PhotoEditing_iOS

/// Integration тесты для EditOperationManager и операций
class EditOperationIntegrationTests: XCTestCase {
    
    var manager: EditOperationManager!
    var testImage: CIImage!
    
    override func setUp() {
        super.setUp()
        manager = EditOperationManager()
        testImage = TestHelpers.createTestImage()
        manager.setOriginalImage(testImage)
    }
    
    override func tearDown() {
        manager = nil
        testImage = nil
        super.tearDown()
    }
    
    // MARK: - Complex Operation Sequences
    
    func testComplexEditingWorkflow() {
        // Simulate a real editing workflow
        
        // 1. Apply exposure adjustment
        let exposure = AdjustmentOperation(adjustmentType: .exposure, value: 0.5)
        manager.addOperation(exposure)
        XCTAssertEqual(manager.operations.count, 1)
        
        // 2. Apply contrast
        let contrast = AdjustmentOperation(adjustmentType: .contrast, value: 1.2)
        manager.addOperation(contrast)
        XCTAssertEqual(manager.operations.count, 2)
        
        // 3. Apply filter with LUT
        let filter = FilterOperation(
            filterName: "Vintage",
            lutIdentifier: "vintage_lut",
            parameters: ["saturation": 0.8]
        )
        manager.addOperation(filter)
        XCTAssertEqual(manager.operations.count, 3)
        
        // 4. Add text
        let text = TextOperation(text: "Hello", position: CGPoint(x: 50, y: 50))
        manager.addOperation(text)
        XCTAssertEqual(manager.operations.count, 4)
        
        // 5. Verify final state
        XCTAssertEqual(manager.currentIndex, 3)
        XCTAssertTrue(manager.canUndo)
        XCTAssertFalse(manager.canRedo)
        
        // 6. Get final image
        let finalImage = manager.getCurrentImage()
        TestHelpers.assertImageNotEmpty(finalImage)
    }
    
    func testUndoRedoWorkflow() {
        // Add multiple operations
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        manager.addOperation(FilterOperation(filterName: "Test"))
        
        // Undo all
        manager.undo()
        XCTAssertEqual(manager.currentIndex, 1)
        manager.undo()
        XCTAssertEqual(manager.currentIndex, 0)
        manager.undo()
        XCTAssertEqual(manager.currentIndex, -1)
        
        // Redo all
        manager.redo()
        XCTAssertEqual(manager.currentIndex, 0)
        manager.redo()
        XCTAssertEqual(manager.currentIndex, 1)
        manager.redo()
        XCTAssertEqual(manager.currentIndex, 2)
        
        // Verify operations are intact
        XCTAssertEqual(manager.operations.count, 3)
    }
    
    func testBranchingHistory() {
        // Create initial operations
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        
        // Undo to middle
        manager.undo()
        XCTAssertEqual(manager.operations.count, 3)
        XCTAssertEqual(manager.currentIndex, 1)
        
        // Add new operation (should clear redo history)
        manager.addOperation(FilterOperation(filterName: "Filter2"))
        XCTAssertEqual(manager.operations.count, 3)
        XCTAssertEqual(manager.currentIndex, 2)
        XCTAssertFalse(manager.canRedo)
        
        // Verify the new operation replaced the old one
        let lastOp = manager.operations.last
        XCTAssertEqual(lastOp?.type, .filter)
    }
    
    func testMultipleFilterApplications() {
        // Apply same filter multiple times with different parameters
        for i in 0..<5 {
            let filter = FilterOperation(
                filterName: "Test",
                parameters: ["exposure": Double(i) * 0.1]
            )
            manager.addOperation(filter)
        }
        
        XCTAssertEqual(manager.operations.count, 5)
        
        // Verify all are filter operations
        let filters = manager.getOperations(ofType: .filter)
        XCTAssertEqual(filters.count, 5)
    }
    
    // MARK: - Snapshot and Restore
    
    func testSnapshotRestoreWorkflow() {
        // Create state 1
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        let snapshot1 = manager.createSnapshot()
        
        // Create state 2
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        manager.addOperation(TextOperation(text: "Test"))
        let snapshot2 = manager.createSnapshot()
        
        // Add more operations
        manager.addOperation(AdjustmentOperation(adjustmentType: .saturation, value: 1.5))
        XCTAssertEqual(manager.operations.count, 5)
        
        // Restore to state 2
        manager.restore(from: snapshot2)
        XCTAssertEqual(manager.operations.count, 4)
        
        // Restore to state 1
        manager.restore(from: snapshot1)
        XCTAssertEqual(manager.operations.count, 2)
    }
    
    // MARK: - Export and Import
    
    func testExportImportComplexWorkflow() throws {
        // Create complex editing session
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        manager.addOperation(FilterOperation(
            filterName: "Vintage",
            lutIdentifier: "vintage_lut",
            parameters: ["saturation": 0.8, "fade": 0.3]
        ))
        manager.addOperation(TextOperation(
            text: "Hello World",
            position: CGPoint(x: 100, y: 200),
            fontSize: 32,
            color: .red
        ))
        
        // Export
        let exportData = manager.exportOperations()
        XCTAssertNotNil(exportData)
        
        // Create new manager and import
        let newManager = EditOperationManager()
        try newManager.importOperations(from: exportData!)
        
        // Verify
        XCTAssertEqual(newManager.operations.count, manager.operations.count)
        XCTAssertEqual(newManager.currentIndex, manager.currentIndex)
        
        // Verify operation types
        for (index, operation) in newManager.operations.enumerated() {
            XCTAssertEqual(operation.type, manager.operations[index].type)
        }
    }
    
    // MARK: - Statistics
    
    func testStatisticsCalculation() {
        // Add various operations
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        manager.addOperation(FilterOperation(filterName: "Filter2"))
        manager.addOperation(TextOperation(text: "Test"))
        
        // Get statistics
        let stats = manager.getStatistics()
        
        XCTAssertEqual(stats.totalOperations, 5)
        XCTAssertEqual(stats.activeOperations, 5)
        XCTAssertEqual(stats.operationsByType[.adjustment], 2)
        XCTAssertEqual(stats.operationsByType[.filter], 2)
        XCTAssertEqual(stats.operationsByType[.text], 1)
    }
    
    func testStatisticsAfterUndoRedo() {
        // Add operations
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        manager.addOperation(TextOperation(text: "Test"))
        
        // Undo one
        manager.undo()
        
        let stats = manager.getStatistics()
        XCTAssertEqual(stats.totalOperations, 3)
        XCTAssertEqual(stats.activeOperations, 2)
    }
    
    // MARK: - Edge Cases
    
    func testRapidOperationAddition() {
        // Simulate rapid user interactions
        for i in 0..<100 {
            if i % 2 == 0 {
                manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.01))
            } else {
                manager.addOperation(FilterOperation(filterName: "Filter\(i)"))
            }
        }
        
        XCTAssertEqual(manager.operations.count, 100)
        XCTAssertEqual(manager.currentIndex, 99)
    }
    
    func testAlternatingUndoRedo() {
        // Add operations
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        
        // Alternate undo/redo multiple times
        for _ in 0..<10 {
            manager.undo()
            manager.redo()
        }
        
        // Should be in original state
        XCTAssertEqual(manager.currentIndex, 1)
        XCTAssertEqual(manager.operations.count, 2)
    }
    
    func testRemoveOperationsWhileEditing() {
        // Add operations
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        let filterOp = FilterOperation(filterName: "Filter1")
        manager.addOperation(filterOp)
        manager.addOperation(TextOperation(text: "Test"))
        
        // Remove middle operation
        manager.removeOperation(at: 2)
        
        XCTAssertEqual(manager.operations.count, 3)
        XCTAssertEqual(manager.currentIndex, 2)
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_AddingManyOperations() {
        measure {
            let tempManager = EditOperationManager()
            tempManager.setOriginalImage(testImage)
            
            for i in 0..<100 {
                tempManager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.01))
            }
        }
    }
    
    func testPerformance_UndoRedoCycle() {
        // Setup
        for i in 0..<50 {
            manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.01))
        }
        
        measure {
            // Undo all
            for _ in 0..<50 {
                manager.undo()
            }
            
            // Redo all
            for _ in 0..<50 {
                manager.redo()
            }
        }
    }
    
    func testPerformance_GetCurrentImage() {
        // Add multiple operations
        for i in 0..<10 {
            manager.addOperation(AdjustmentOperation(
                adjustmentType: .exposure,
                value: Double(i) * 0.05
            ))
        }
        
        measure {
            _ = manager.getCurrentImage()
        }
    }
    
    func testPerformance_ExportOperations() {
        // Add many operations
        for i in 0..<50 {
            if i % 2 == 0 {
                manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.01))
            } else {
                manager.addOperation(FilterOperation(filterName: "Filter\(i)"))
            }
        }
        
        measure {
            _ = manager.exportOperations()
        }
    }
    
    // MARK: - Memory Tests
    
    func testMemoryManagement_LargeOperationCount() {
        // Add many operations
        for i in 0..<1000 {
            manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.001))
        }
        
        XCTAssertEqual(manager.operations.count, 1000)
        
        // Clear should free memory
        manager.clear()
        XCTAssertEqual(manager.operations.count, 0)
    }
    
    func testMemoryManagement_SnapshotRetention() {
        // Create multiple snapshots
        var snapshots: [EditOperationSnapshot] = []
        
        for i in 0..<10 {
            manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.1))
            snapshots.append(manager.createSnapshot())
        }
        
        XCTAssertEqual(snapshots.count, 10)
        
        // Clear manager
        manager.clear()
        
        // Snapshots should still be valid
        XCTAssertGreaterThan(snapshots[0].operations.count, 0)
    }
}

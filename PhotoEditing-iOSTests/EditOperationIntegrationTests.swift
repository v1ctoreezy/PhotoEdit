import XCTest
import CoreImage
import SwiftUI
import PixelEnginePackage
@testable import PhotoEditing_iOS

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
    
    
    func testComplexEditingWorkflow() {
        
        let exposure = AdjustmentOperation(adjustmentType: .exposure, value: 0.5)
        manager.addOperation(exposure)
        XCTAssertEqual(manager.operations.count, 1)
        
        let contrast = AdjustmentOperation(adjustmentType: .contrast, value: 1.2)
        manager.addOperation(contrast)
        XCTAssertEqual(manager.operations.count, 2)
        
        let filter = FilterOperation(
            filterName: "Vintage",
            lutIdentifier: "vintage_lut",
            parameters: ["saturation": 0.8]
        )
        manager.addOperation(filter)
        XCTAssertEqual(manager.operations.count, 3)
        
        let text = TextOperation(text: "Hello", position: CGPoint(x: 50, y: 50))
        manager.addOperation(text)
        XCTAssertEqual(manager.operations.count, 4)
        
        XCTAssertEqual(manager.currentIndex, 3)
        XCTAssertTrue(manager.canUndo)
        XCTAssertFalse(manager.canRedo)
        
        let finalImage = manager.getCurrentImage()
        TestHelpers.assertImageNotEmpty(finalImage)
    }
    
    func testUndoRedoWorkflow() {
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        manager.addOperation(FilterOperation(filterName: "Test"))
        
        manager.undo()
        XCTAssertEqual(manager.currentIndex, 1)
        manager.undo()
        XCTAssertEqual(manager.currentIndex, 0)
        manager.undo()
        XCTAssertEqual(manager.currentIndex, -1)
        
        manager.redo()
        XCTAssertEqual(manager.currentIndex, 0)
        manager.redo()
        XCTAssertEqual(manager.currentIndex, 1)
        manager.redo()
        XCTAssertEqual(manager.currentIndex, 2)
        
        XCTAssertEqual(manager.operations.count, 3)
    }
    
    func testBranchingHistory() {
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        
        manager.undo()
        XCTAssertEqual(manager.operations.count, 3)
        XCTAssertEqual(manager.currentIndex, 1)
        
        manager.addOperation(FilterOperation(filterName: "Filter2"))
        XCTAssertEqual(manager.operations.count, 3)
        XCTAssertEqual(manager.currentIndex, 2)
        XCTAssertFalse(manager.canRedo)
        
        let lastOp = manager.operations.last
        XCTAssertEqual(lastOp?.type, .filter)
    }
    
    func testMultipleFilterApplications() {
        for i in 0..<5 {
            let filter = FilterOperation(
                filterName: "Test",
                parameters: ["exposure": Double(i) * 0.1]
            )
            manager.addOperation(filter)
        }
        
        XCTAssertEqual(manager.operations.count, 5)
        
        let filters = manager.getOperations(ofType: .filter)
        XCTAssertEqual(filters.count, 5)
    }
    
    
    func testSnapshotRestoreWorkflow() {
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        let snapshot1 = manager.createSnapshot()
        
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        manager.addOperation(TextOperation(text: "Test"))
        let snapshot2 = manager.createSnapshot()
        
        manager.addOperation(AdjustmentOperation(adjustmentType: .saturation, value: 1.5))
        XCTAssertEqual(manager.operations.count, 5)
        
        manager.restore(from: snapshot2)
        XCTAssertEqual(manager.operations.count, 4)
        
        manager.restore(from: snapshot1)
        XCTAssertEqual(manager.operations.count, 2)
    }
    
    
    func testExportImportComplexWorkflow() throws {
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
        
        let exportData = manager.exportOperations()
        XCTAssertNotNil(exportData)
        
        let newManager = EditOperationManager()
        try newManager.importOperations(from: exportData!)
        
        XCTAssertEqual(newManager.operations.count, manager.operations.count)
        XCTAssertEqual(newManager.currentIndex, manager.currentIndex)
        
        for (index, operation) in newManager.operations.enumerated() {
            XCTAssertEqual(operation.type, manager.operations[index].type)
        }
    }
    
    
    func testStatisticsCalculation() {
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        manager.addOperation(FilterOperation(filterName: "Filter2"))
        manager.addOperation(TextOperation(text: "Test"))
        
        let stats = manager.getStatistics()
        
        XCTAssertEqual(stats.totalOperations, 5)
        XCTAssertEqual(stats.activeOperations, 5)
        XCTAssertEqual(stats.operationsByType[.adjustment], 2)
        XCTAssertEqual(stats.operationsByType[.filter], 2)
        XCTAssertEqual(stats.operationsByType[.text], 1)
    }
    
    func testStatisticsAfterUndoRedo() {
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(FilterOperation(filterName: "Filter1"))
        manager.addOperation(TextOperation(text: "Test"))
        
        manager.undo()
        
        let stats = manager.getStatistics()
        XCTAssertEqual(stats.totalOperations, 3)
        XCTAssertEqual(stats.activeOperations, 2)
    }
    
    
    func testRapidOperationAddition() {
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
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        
        for _ in 0..<10 {
            manager.undo()
            manager.redo()
        }
        
        XCTAssertEqual(manager.currentIndex, 1)
        XCTAssertEqual(manager.operations.count, 2)
    }
    
    func testRemoveOperationsWhileEditing() {
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.5))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        let filterOp = FilterOperation(filterName: "Filter1")
        manager.addOperation(filterOp)
        manager.addOperation(TextOperation(text: "Test"))
        
        manager.removeOperation(at: 2)
        
        XCTAssertEqual(manager.operations.count, 3)
        XCTAssertEqual(manager.currentIndex, 2)
    }
    
    
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
        for i in 0..<50 {
            manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.01))
        }
        
        measure {
            for _ in 0..<50 {
                manager.undo()
            }
            
            for _ in 0..<50 {
                manager.redo()
            }
        }
    }
    
    func testPerformance_GetCurrentImage() {
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
    
    
    func testMemoryManagement_LargeOperationCount() {
        for i in 0..<1000 {
            manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.001))
        }
        
        XCTAssertEqual(manager.operations.count, 1000)
        
        manager.clear()
        XCTAssertEqual(manager.operations.count, 0)
    }
    
    func testMemoryManagement_SnapshotRetention() {
        var snapshots: [EditOperationSnapshot] = []
        
        for i in 0..<10 {
            manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: Double(i) * 0.1))
            snapshots.append(manager.createSnapshot())
        }
        
        XCTAssertEqual(snapshots.count, 10)
        
        manager.clear()
        
        XCTAssertGreaterThan(snapshots[0].operations.count, 0)
    }
}

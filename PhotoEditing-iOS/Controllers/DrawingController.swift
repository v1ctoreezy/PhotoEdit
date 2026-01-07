import Foundation
import SwiftUI
import PencilKit

class DrawingController: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isDrawingMode: Bool = false
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    @Published var drawing: PKDrawing = PKDrawing()
    
    // Canvas reference for undo/redo
    weak var canvasView: PKCanvasView?
    
    // MARK: - Public Methods
    
    func setCanvasView(_ canvas: PKCanvasView) {
        self.canvasView = canvas
        updateUndoRedoState()
    }
    
    func startDrawing() {
        isDrawingMode = true
    }
    
    func stopDrawing() {
        isDrawingMode = false
    }
    
    func clearDrawing() {
        drawing = PKDrawing()
        canvasView?.drawing = PKDrawing()
        updateUndoRedoState()
    }
    
    func undo() {
        canvasView?.undoManager?.undo()
        updateUndoRedoState()
    }
    
    func redo() {
        canvasView?.undoManager?.redo()
        updateUndoRedoState()
    }
    
    func updateDrawing(_ newDrawing: PKDrawing) {
        drawing = newDrawing
        updateUndoRedoState()
    }
    
    func hasDrawing() -> Bool {
        return !drawing.strokes.isEmpty
    }
    
    func getDrawingImage(size: CGSize) -> UIImage? {
        guard !drawing.strokes.isEmpty else { return nil }
        
        // Create image from drawing with transparent background
        let bounds = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { context in
            // Draw on transparent background
            UIColor.clear.setFill()
            context.fill(bounds)
            
            // Draw the PKDrawing
            drawing.image(from: drawing.bounds, scale: 1.0).draw(in: bounds)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUndoRedoState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.canUndo = self.canvasView?.undoManager?.canUndo ?? false
            self.canRedo = self.canvasView?.undoManager?.canRedo ?? false
        }
    }
    
    func reset() {
        clearDrawing()
        isDrawingMode = false
    }
}


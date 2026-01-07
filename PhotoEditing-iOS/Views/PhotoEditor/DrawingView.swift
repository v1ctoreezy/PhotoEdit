import SwiftUI
import PencilKit

struct DrawingView: View {
    
    @EnvironmentObject var shared: PhotoEditingController
    @Environment(\.presentationMode) var presentationMode
    
    @State private var canvasView: PKCanvasView = PKCanvasView()
    @State private var toolPicker: PKToolPicker = PKToolPicker()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Preview image as background
                    if let image = shared.previewImage {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // Canvas overlay
                            DrawingCanvasView(
                                canvasView: $canvasView,
                                drawing: $shared.drawingCtrl.drawing,
                                onDrawingChanged: { newDrawing in
                                    shared.drawingCtrl.updateDrawing(newDrawing)
                                }
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Bottom toolbar
                    HStack(spacing: 20) {
                        Button(action: {
                            shared.drawingCtrl.undo()
                        }) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 22))
                                .foregroundColor(shared.drawingCtrl.canUndo ? .white : .gray)
                        }
                        .disabled(!shared.drawingCtrl.canUndo)
                        
                        Button(action: {
                            shared.drawingCtrl.redo()
                        }) {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: 22))
                                .foregroundColor(shared.drawingCtrl.canRedo ? .white : .gray)
                        }
                        .disabled(!shared.drawingCtrl.canRedo)
                        
                        Spacer()
                        
                        Button(action: {
                            shared.drawingCtrl.clearDrawing()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Очистить")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .frame(height: 60)
                    .background(Color.black.opacity(0.8))
                }
            }
            .navigationBarTitle("Рисование", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    // Reset drawing if user cancels
                    shared.drawingCtrl.clearDrawing()
                    shared.drawingCtrl.stopDrawing()
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Готово") {
                    // Apply drawing
                    shared.didReceive(action: .applyDrawing)
                    shared.drawingCtrl.stopDrawing()
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.bold)
            )
            .onAppear {
                shared.drawingCtrl.setCanvasView(canvasView)
                shared.drawingCtrl.startDrawing()
                
                // Show tool picker
                toolPicker.setVisible(true, forFirstResponder: canvasView)
                toolPicker.addObserver(canvasView)
                canvasView.becomeFirstResponder()
            }
            .onDisappear {
                toolPicker.setVisible(false, forFirstResponder: canvasView)
                toolPicker.removeObserver(canvasView)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Canvas View Wrapper

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing
    var onDrawingChanged: (PKDrawing) -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawing = drawing
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 10)
        canvasView.delegate = context.coordinator
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Only update if drawing changed externally
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, onDrawingChanged: onDrawingChanged)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var onDrawingChanged: (PKDrawing) -> Void
        
        init(drawing: Binding<PKDrawing>, onDrawingChanged: @escaping (PKDrawing) -> Void) {
            self._drawing = drawing
            self.onDrawingChanged = onDrawingChanged
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
            onDrawingChanged(canvasView.drawing)
        }
    }
}


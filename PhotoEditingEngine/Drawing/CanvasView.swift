//
//  CanvasView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 06.09.2025.
//

import SwiftUI
import PencilKit

struct SUICanvasCommandsMessage: Identifiable {
    let id: UUID = UUID()
    let command: SUICanvasCommands
}

struct SUICanvasView: View {
    @State var imageView = UIImageView()
    @State private var canvas = Canvas()
    
    @State private var canvasController: CanvasViewController<Canvas>?
    
    @Binding var canvasCommands: SUICanvasCommandsMessage

    @Binding var image: UIImage
    @Binding var showTools: Bool
    
    init(image: Binding<UIImage>, hideToolPicker: Binding<Bool>, canvasCommands: Binding<SUICanvasCommandsMessage>) {
        self._image = image
        self._showTools = hideToolPicker
        self._canvasCommands = canvasCommands
    }
    
    var body: some View {
        ZStack {
            ImageView(
                image: Binding(get: { image }, set: { _ in }),
                imageView: imageView,
                contentMode: Binding(
                    get: { .scaleAspectFill },
                    set: { _ in }
                )
            )
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .overlay(
                CanvasView(canvas: $canvas, canvasCommands: $canvasCommands, onChanged: { drawing in }, onSelectionChanged: { _ in })
                .onAppear {
//                            mlCanvas.mainCanvas = canvas
//                            canvas.mlCanvas = mlCanvas
                }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
            )
            
        }
    }
}

enum SUICanvasCommands {
    case initial
    case showText(title: String, text: String, actionTitle: String)
    case showTools(Bool)
    case undo
}

fileprivate struct CanvasView<T: PKCanvasView>: UIViewControllerRepresentable {
    typealias UIViewControllerType = CanvasViewController<T>
    
    /// PKCanvasView object
    @Binding var canvas: T
    
    @Binding var canvasCommands: SUICanvasCommandsMessage
        
    /// Canvas drawing changed
    var onChanged: ((PKDrawing) -> Void)?
    
    /// Selected subview changed
    var onSelectionChanged: ((UIView?) -> Void)?
    
    /// Set as main responder for UIWindow
    var shouldBecameFirstResponder: Bool = true
        
    func makeUIViewController(context: Context) -> UIViewControllerType {
      let controller = CanvasViewController(
            canvas: canvas,
            onChanged: onChanged,
            onSelectionChanged: onSelectionChanged,
            shouldBecameFirstResponder: shouldBecameFirstResponder
        )
        context.coordinator.viewController = controller
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        switch canvasCommands.command {
        case .showText(let title, let text, let actionTitle):
            context.coordinator.showText(title: title, text: text, actionTitle: actionTitle)
        case .showTools(let bool):
            context.coordinator.toolPicker(show: bool)
        case .undo:
            context.coordinator.viewController?.canvas.undoManager?.undo()
        case .initial:
            break;
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
        private var isToolpickerOnScreen: Bool = true
        
        weak var viewController: CanvasViewController<T>?

        func showText(title: String, text: String, actionTitle: String) {
            viewController?.showTextAlert(
                title: title,
                text: text,
                actionTitle: actionTitle,
                onCancel: { [weak self] in
                    guard let self = self else { return }
                    self.toolPicker(show: self.isToolpickerOnScreen)
                }
            ) { [weak self] in
                guard let self = self else { return }
                self.toolPicker(show: self.isToolpickerOnScreen)
            }
        }
        
        func toolPicker(show: Bool) {
            viewController?.canvas.becomeFirstResponder()
            viewController?.toolPicker?.setVisible(show, forFirstResponder: viewController!.canvas)
            isToolpickerOnScreen = viewController?.toolPicker?.isVisible ?? false
        }
    }
}

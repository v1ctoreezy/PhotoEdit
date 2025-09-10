//
//  CanvasView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 06.09.2025.
//

import SwiftUI
import PencilKit

extension UIResponder {
    /// Access parent controller
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}


struct SUICanvasView: View {
    @State var imageView = UIImageView()
    @State private var canvas = Canvas()
    
    @State private var canvasController: CanvasViewController<Canvas>?
    
    @Binding var canvasCommands: SUICanvasCommands

    @Binding var image: UIImage
    @Binding var showTools: Bool
    
    init(image: Binding<UIImage>, hideToolPicker: Binding<Bool>, canvasCommands: Binding<SUICanvasCommands>) {
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
                    get: { .scaleAspectFit },
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
    case showText
    case showTools(Bool)
}

struct CanvasView<T: PKCanvasView>: UIViewControllerRepresentable {
    typealias UIViewControllerType = CanvasViewController<T>
    
    /// PKCanvasView object
    @Binding var canvas: T
    
    @Binding var canvasCommands: SUICanvasCommands
        
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
        switch canvasCommands {
        case .showText:
            context.coordinator.showText()
        case .showTools(let bool):
            context.coordinator.toolPicker(show: bool)
        case .initial:
            break;
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(canvasCommands: $canvasCommands)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
        @Binding var canvasCommands: SUICanvasCommands
        
        weak var viewController: CanvasViewController<T>?
        
        init(canvasCommands: Binding<SUICanvasCommands>) {
            self._canvasCommands = canvasCommands
        }

        func showText() {
            viewController?.showTextAlert(title: "DSADA", text: "DSAD", actionTitle: "DSADA")
        }
        
        func toolPicker(show: Bool) {
            viewController?.canvas.becomeFirstResponder()
            viewController?.toolPicker?.setVisible(show, forFirstResponder: viewController!.canvas)
        }
    }
}

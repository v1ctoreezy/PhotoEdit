import SwiftUI

struct PhotoEditorView: View {
    
    @EnvironmentObject  var shared: PhotoEditingController
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                if let image = shared.previewImage{
                    GeometryReader { geometry in
                        ZStack {
                            ImagePreviewView(image: image)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                            
                            // Text overlay
                            ForEach(shared.textCtrl.textElements) { textElement in
                                DraggableTextView(
                                    textElement: textElement,
                                    containerSize: geometry.size,
                                    onPositionChange: { newPosition in
                                        shared.textCtrl.updatePosition(
                                            id: textElement.id,
                                            newPosition: newPosition
                                        )
                                    }
                                )
                            }
                        }
                    }
                }else{
                    Rectangle()
                        .fill(Color.myGrayDark)
                }
                EditMenuView()
                    .frame(height: 250)
            }
        }
    }
}

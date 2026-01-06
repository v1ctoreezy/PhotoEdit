import SwiftUI

struct PhotoEditorView: View {
    
    @EnvironmentObject  var shared: PhotoEditingController
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                if let image = shared.previewImage{
                    ImagePreviewView(image: image)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
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

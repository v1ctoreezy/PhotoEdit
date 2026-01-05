import SwiftUI

struct ImagePreviewView: View {
    var image:UIImage
    
    @State var  contentMode:ContentMode = .fit
    
    var body: some View {
        GeometryReader { geo in
            Image(uiImage: self.image)
                .resizable()
                .aspectRatio(contentMode: self.contentMode)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                .onTapGesture(count: 2) {
                    withAnimation{
                        self.contentMode = self.contentMode == .fit ? .fill : .fit
                    }
                }
        }
    }
}

struct ImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePreviewView(image: UIImage(named: "carem")!)
    }
}

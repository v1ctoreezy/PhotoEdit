import SwiftUI

struct IconButton: View {
    var image:String
    var size:CGFloat
    
    init(_ image:String, size:CGFloat = 32) {
        self.image = image
        self.size = size
    }
    var body: some View {
        Image(self.image)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: self.size, height: self.size)
    }
}

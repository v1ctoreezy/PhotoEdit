import SwiftUI

struct IconButton: View {
    var image: String
    var size: CGFloat
    var isSystemImage: Bool
    
    init(_ image: String, size: CGFloat = 32, isSystemImage: Bool = true) {
        self.image = image
        self.size = size
        self.isSystemImage = isSystemImage
    }
    
    var body: some View {
        Group {
            if isSystemImage {
                Image(systemName: image)
                    .font(.system(size: size * 0.6))
                    .frame(width: size, height: size)
            } else {
                Image(image)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
        }
    }
}

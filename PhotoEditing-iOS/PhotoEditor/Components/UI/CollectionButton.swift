import SwiftUI

struct CollectionButton: View {
    var name:String
    
    @EnvironmentObject var shared: PhotoEditingController
    
    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Color.myGrayLight)
    }
}

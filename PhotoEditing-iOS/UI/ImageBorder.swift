import SwiftUI

struct ImageBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .border(Color.white, width: 1)
    }
}

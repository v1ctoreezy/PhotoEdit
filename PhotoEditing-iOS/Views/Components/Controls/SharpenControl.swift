import SwiftUI
import PixelEnginePackage

struct SharpenControl: View {
    var body: some View {
        GenericFilterControl(config: SharpenConfiguration())
    }
}

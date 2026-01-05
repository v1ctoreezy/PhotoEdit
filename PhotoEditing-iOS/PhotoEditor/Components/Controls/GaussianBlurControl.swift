import SwiftUI
import PixelEnginePackage

struct GaussianBlurControl: View {
    var body: some View {
        GenericFilterControl(config: GaussianBlurConfiguration())
    }
}

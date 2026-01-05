import SwiftUI
import PixelEnginePackage

struct SaturationControl: View {
    var body: some View {
        GenericFilterControl(config: SaturationConfiguration())
    }
}

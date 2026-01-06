import SwiftUI
import PixelEnginePackage

struct ExposureControl: View {
    var body: some View {
        GenericFilterControl(config: ExposureConfiguration())
    }
}

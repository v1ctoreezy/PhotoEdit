import SwiftUI
import PixelEnginePackage

struct TemperatureControl: View {
    var body: some View {
        GenericFilterControl(config: TemperatureConfiguration())
    }
}

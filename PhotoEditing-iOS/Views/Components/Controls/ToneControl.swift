import SwiftUI
import PixelEnginePackage

struct ToneControl: View {
    var body: some View {
        VStack(spacing: 24) {
            GenericFilterControl(config: HighlightsConfiguration(
                withLabel: "Highlights",
                withRangeDisplay: (0, 100),
                spacing: 8
            ))
            
            GenericFilterControl(config: ShadowsConfiguration(
                withLabel: "Shadows",
                spacing: 8
            ))
        }
    }
}

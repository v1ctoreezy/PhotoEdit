import SwiftUI
import PixelEnginePackage

struct WhiteBalanceControl: View {
    @State private var temperatureIntensity: Double = 0
    @State private var tintIntensity: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            FilterSlider(
                value: Binding(
                    get: { temperatureIntensity },
                    set: { temperatureIntensity = $0; valueChanged() }
                ),
                range: (FilterWhiteBalance.range.min, FilterWhiteBalance.range.max),
                lable: "Temperature",
                defaultValue: 0,
                spacing: 8
            )
            
            FilterSlider(
                value: Binding(
                    get: { tintIntensity },
                    set: { tintIntensity = $0; valueChanged() }
                ),
                range: (FilterWhiteBalance.range.min, FilterWhiteBalance.range.max),
                lable: "Tint",
                defaultValue: 0,
                spacing: 8
            )
        }
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    private func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        temperatureIntensity = edit.filters.whiteBalance?.valueTemperature ?? 0
        tintIntensity = edit.filters.whiteBalance?.valueTint ?? 0
    }
    
    private func valueChanged() {
        let valueTemperature = temperatureIntensity
        let valueTint = tintIntensity
        
        guard valueTemperature != 0 || valueTint != 0 else {
            PhotoEditingController.shared.didReceive(
                action: PhotoEditingControllerAction.setFilter({ $0.whiteBalance = nil })
            )
            return
        }
        
        var filter = FilterWhiteBalance()
        filter.valueTint = valueTint
        filter.valueTemperature = valueTemperature
        PhotoEditingController.shared.didReceive(
            action: PhotoEditingControllerAction.setFilter({ $0.whiteBalance = filter })
        )
    }
}

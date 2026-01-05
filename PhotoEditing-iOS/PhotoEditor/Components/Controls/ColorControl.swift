import SwiftUI
import PixelEnginePackage

struct ColorControl: View {
    @State var filterIntensity:Double = 0
    
    // Todo: Missing Saturation, Contrast
    var body: some View {
        
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
        },
            set: {
                self.filterIntensity = $0
                self.valueChanged()
        }
        )
        
        let min = FilterColor.rangeBrightness.min
        let max = FilterColor.rangeBrightness.max
        return  FilterSlider(value: intensity, range: (min, max), defaultValue: 0)
            .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        self.filterIntensity = edit.filters.color?.valueBrightness ?? 0
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        
        guard value != 0 else {
            PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.color = nil }))
            return
        }
        
        var f = FilterColor()
        f.valueBrightness = value
        PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.color = f }))
    }
}

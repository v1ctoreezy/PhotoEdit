import SwiftUI
import PixelEnginePackage

struct ExposureControl: View {
    @State var filterIntensity:Double = 0
    
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
        let min = FilterExposure.range.min
        let max = FilterExposure.range.max
        return  FilterSlider(value: intensity, range: (min, max), defaultValue: 0)
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        self.filterIntensity = edit.filters.exposure?.value ?? 0
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        
        guard value != 0 else {
            PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.exposure = nil }))
            return
        }
        
        var f = FilterExposure()
        f.value = value
        PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.exposure = f }))
    }
}

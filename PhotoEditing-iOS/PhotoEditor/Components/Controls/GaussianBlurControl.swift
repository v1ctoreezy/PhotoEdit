import SwiftUI
import PixelEnginePackage

struct GaussianBlurControl: View {
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
        let min = FilterGaussianBlur.range.min
        let max = FilterGaussianBlur.range.max
        return  FilterSlider(value: intensity, range: (min, max), defaultValue: 0)
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        self.filterIntensity = edit.filters.gaussianBlur?.value ?? 0
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        
        guard value != 0 else {
            PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.gaussianBlur = nil }))
            return
        }
        
        var f = FilterGaussianBlur()
        f.value = value
        PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.gaussianBlur = f }))
    }
}

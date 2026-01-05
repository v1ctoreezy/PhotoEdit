import SwiftUI
import PixelEnginePackage

struct ContrastControl: View {
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
        let min = FilterContrast.range.min
        let max = FilterContrast.range.max
        return  FilterSlider(value: intensity, range: (min, max), defaultValue: 0)
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        self.filterIntensity = edit.filters.contrast?.value ?? 0
    }
    
    func valueChanged() {
        let value = self.filterIntensity
        
        guard value != 0 else {
            PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.contrast = nil }))
            return
        }
        
        var f = FilterContrast()
        f.value = value
        PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.contrast = f }))
    }
}

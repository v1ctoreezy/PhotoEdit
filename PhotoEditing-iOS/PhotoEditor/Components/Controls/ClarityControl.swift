import SwiftUI
import PixelEnginePackage

struct ClarityCode: View {
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
        
        return  FilterSlider(value: intensity, range: (0, 1), defaultValue: 0, rangeDisplay: (0, 100))
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        self.filterIntensity = edit.filters.unsharpMask?.intensity ?? 0
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        
        guard value != 0 else {
            PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.unsharpMask = nil }))
            return
        }
        
        var f = FilterUnsharpMask()
        f.intensity = value
        f.radius = 0.12
        PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.unsharpMask = f }))
    }
}

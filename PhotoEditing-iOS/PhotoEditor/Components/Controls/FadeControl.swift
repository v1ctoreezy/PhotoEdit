import SwiftUI
import PixelEnginePackage

struct FadeControl: View {
    
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
        return  FilterSlider(value: intensity, range: (0, 1), defaultValue: 0, rangeDisplay: (0, 100)).onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        self.filterIntensity = edit.filters.fade?.intensity ?? 0
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        
        guard value != 0 else {
            PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.fade = nil }))
            return
        }
        
        var f = FilterFade()
        f.intensity = value
        PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.fade = f }))
    }
}

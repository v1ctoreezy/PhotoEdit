import SwiftUI
import PixelEnginePackage

struct ColorCubeControl: View {
    
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
        self.filterIntensity = edit.filters.colorCube?.amount ?? 1
    }
    
    func valueChanged() {
        guard let filter = PhotoEditingController.shared.editState?.currentEdit.filters.colorCube else {
            return
        }
        
        let value = self.filterIntensity
        let clone = FilterColorCube(name: filter.name, identifier: filter.identifier, filter: filter.filter, amount: value)
       
        PhotoEditingController.shared.didReceive(action: PhotoEditingControllerAction.setFilter({ $0.colorCube = clone }))
    }
}

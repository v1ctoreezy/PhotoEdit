import SwiftUI
import PixelEnginePackage

struct ColorCubeControl: View {
    @State private var filterIntensity: Double = 0
    
    var body: some View {
        FilterSlider(
            value: Binding(
                get: { filterIntensity },
                set: { filterIntensity = $0; valueChanged() }
            ),
            range: (0, 1),
            defaultValue: 0,
            rangeDisplay: (0, 100)
        )
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    private func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        filterIntensity = edit.filters.colorCube?.amount ?? 1
    }
    
    private func valueChanged() {
        guard let filter = PhotoEditingController.shared.editState?.currentEdit.filters.colorCube else {
            return
        }
        
        let clone = FilterColorCube(
            name: filter.name,
            identifier: filter.identifier,
            filter: filter.filter,
            amount: filterIntensity
        )
        
        PhotoEditingController.shared.didReceive(
            action: PhotoEditingControllerAction.setFilter({ $0.colorCube = clone })
        )
    }
}

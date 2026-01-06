import QCropper
import Combine
import SwiftUI

class CropperController: ObservableObject {
    
    @Published var state: CropperState?
    
    // Callback to notify when crop state changes
    var onCropChanged: (() -> Void)?
    
    func setState(_ state: CropperState?) {
        self.state = state
        // Notify that crop has been applied
        onCropChanged?()
    }
    
    func reset() {
        state = nil
        onCropChanged?()
    }
}

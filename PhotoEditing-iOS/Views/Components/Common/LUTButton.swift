import SwiftUI
import PixelEnginePackage

// MARK: - Legacy LUT Button (for backward compatibility)
@available(*, deprecated, message: "Use LazyLUTButton instead")
struct LUTButton: View {
    
    var cube:PreviewFilterColorCube
    
    @EnvironmentObject var shared: PhotoEditingController
    
    var body: some View {
        let on = shared.lutsCtrl.currentCube == cube.filter.identifier
        
        return Button(action:{
            if(on){
                self.editAmong()
            }else{
                self.valueChanged()
            }
        }){
            VStack(spacing: 0){
                Image(uiImage: UIImage(cgImage: cube.cgImage))
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 68, height: 68)
                    .clipped()
                Text(cube.filter.name)
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 68, height: 24)
                    .background(on ? Color.myPrimary : Color.myButtonDark)
                    .foregroundColor(.white)
                
            }
            .frame(width: 68)
        }
    }
    
    func valueChanged() {
        shared.lutsCtrl.currentCube = cube.filter.identifier
        shared.didReceive(action: PhotoEditingControllerAction.applyFilter({ $0.colorCube = self.cube.filter }))
    }
    func editAmong(){
        self.shared.lutsCtrl.onSetEditingMode(true)
    }
}

// MARK: - Lazy Loading LUT Button
struct LazyLUTButton: View {
    
    let cubeInfo: FilterColorCubeInfo
    let sourceImage: CIImage?
    
    @EnvironmentObject var shared: PhotoEditingController
    @StateObject private var previewState = LazyPreviewState()
    
    var body: some View {
        let on = shared.lutsCtrl.currentCube == cubeInfo.identifier
        
        return Button(action:{
            if(on){
                self.editAmong()
            }else{
                self.valueChanged()
            }
        }){
            VStack(spacing: 0){
                if let image = previewState.image {
                    Image(uiImage: UIImage(cgImage: image))
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 68, height: 68)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.myGrayDark)
                        .frame(width: 68, height: 68)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
                
                Text(cubeInfo.name)
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 68, height: 24)
                    .background(on ? Color.myPrimary : Color.myButtonDark)
                    .foregroundColor(.white)
                
            }
            .frame(width: 68)
        }
        .onAppear {
            loadPreview(priority: 10) // Higher priority when visible
        }
        .onDisappear {
            // Could cancel loading if needed
        }
    }
    
    private func loadPreview(priority: Int = 0) {
        guard let sourceImage = sourceImage else { return }
        
        let filter = cubeInfo.getFilter()
        previewState.loadPreview(
            identifier: cubeInfo.identifier,
            priority: priority,
            sourceImage: sourceImage,
            filter: filter
        )
    }
    
    func valueChanged() {
        shared.lutsCtrl.currentCube = cubeInfo.identifier
        let filter = cubeInfo.getFilter()
        shared.didReceive(action: PhotoEditingControllerAction.applyFilter({ $0.colorCube = filter }))
    }
    
    func editAmong(){
        self.shared.lutsCtrl.onSetEditingMode(true)
    }
}

struct NeutralButton: View {
    
    var image: UIImage
    @EnvironmentObject var shared: PhotoEditingController
    
    var body: some View {
        let on = shared.lutsCtrl.currentCube.isEmpty
        
        return Button(action:valueChanged){
            VStack(spacing: 0){
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 68, height: 68)
                    .clipped()
                
                Text("Original")
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 68, height: 24)
                    .background(on ? Color.myPrimary : Color.myButtonDark)
                    .foregroundColor(.white)
            }
        }
    }
    
    func valueChanged() {
        shared.lutsCtrl.selectCube("")
        shared.didReceive(action: PhotoEditingControllerAction.applyFilter({ $0.colorCube = nil }))
    }
}

struct LutLoadingButton: View {
    
    var name:String
    var on:Bool
    
    var body: some View {
        return VStack(spacing: 0){
            Rectangle()
                .fill(Color.myGrayDark)
                .frame(width: 68, height: 68)
            
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 68, height: 24)
                .background(on ? Color.myPrimary : Color.myButtonDark)
                .foregroundColor(.white)
        }
    }
    
}

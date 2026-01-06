import SwiftUI
import CoreData
import PixelEnginePackage

// MARK: - Legacy Recipe Button (for backward compatibility)
@available(*, deprecated, message: "Use LazyRecipeButton instead")
struct RecipeButton: View {
    var data: Recipe
    var on:Bool
    var index:Int
    
    @EnvironmentObject var shared: PhotoEditingController
    
    var body: some View {
        return Button(action: valueChanged){
            ZStack{
                VStack(spacing: 0){
                    if(data.preview == nil){
                    Rectangle()
                        .fill(Color.myGrayDark)
                        .frame(width: 68, height: 60)
                    }else{
                    Image(uiImage: data.preview!)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 68, height: 68)
                        .clipped()
                    }
                    
                    Text(data.data.recipeName ?? "Recipe \(index)")
                        .font(.system(size: 11, weight: .medium))
                        .frame(width: 68, height: 24)
                        .background(on ? Color.myPrimary : Color.myButtonDark)
                        .foregroundColor(.white)
                }
                Button(action: deleteItem){
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }.frame(width: 60, height: 76, alignment: .topTrailing)
            }
        }
    }
    func valueChanged() {
        shared.didReceive(action: PhotoEditingControllerAction.applyRecipe(shared.recipesCtrl.recipes[index].data))
    }
    func deleteItem() {
        shared.recipesCtrl.deleteRecipe(index)
    }
}

// MARK: - Lazy Loading Recipe Button
struct LazyRecipeButton: View {
    var data: Recipe
    var on: Bool
    var index: Int
    
    @EnvironmentObject var shared: PhotoEditingController
    @StateObject private var previewState = LazyPreviewState()
    
    var body: some View {
        return Button(action: valueChanged){
            ZStack{
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
                    
                    Text(data.data.recipeName ?? "Recipe \(index)")
                        .font(.system(size: 11, weight: .medium))
                        .frame(width: 68, height: 24)
                        .background(on ? Color.myPrimary : Color.myButtonDark)
                        .foregroundColor(.white)
                }
                Button(action: deleteItem){
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }.frame(width: 60, height: 76, alignment: .topTrailing)
            }
        }
        .onAppear {
            loadPreview(priority: 10) // Higher priority when visible
        }
        .onDisappear {
            // Could cancel loading if needed
        }
    }
    
    private func loadPreview(priority: Int = 0) {
        guard let sourceImage = data.sourceImage else { return }
        
        let colorCube = Data.shared.cubeBy(identifier: data.data.lutIdentifier ?? "")
        let filters = RecipeUtils.applyRecipe(data.data, colorCube: colorCube)
        
        previewState.loadRecipePreview(
            identifier: data.identifier,
            priority: priority,
            sourceImage: sourceImage,
            filters: filters
        )
    }
    
    func valueChanged() {
        shared.didReceive(action: PhotoEditingControllerAction.applyRecipe(shared.recipesCtrl.recipes[index].data))
    }
    func deleteItem() {
        shared.recipesCtrl.deleteRecipe(index)
    }
}

struct RecipeEmptyButton: View {
    var name:String
    var on:Bool
    var action: () -> Void
    
    var body: some View {
        return Button(action: action){
            VStack(spacing: 0){
                Rectangle()
                    .fill(Color.myGrayDark)
                    .frame(width: 68, height: 60)
                
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 68, height: 24)
                    .background(on ? Color.myPrimary : Color.myButtonDark)
                    .foregroundColor(.white)
            }
        }
    }
}

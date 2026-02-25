import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import CoreData

class RecipeController : ObservableObject{
    @Published var recipes: [Recipe] = []
    
    var sourceImage:CIImage?
    
    var controller: PhotoEditingController {
        get {
            PhotoEditingController.shared
        }
    }
    
    init(){
        let data = RecipeUtils.loadRecipe()
        self.recipes = []
        for e in data {
            let item = Recipe(data: e)
            recipes.append(item)
        }
    }
    
    func setImage(image:CIImage){
        self.sourceImage = image
        for e in self.recipes {
            e.setSourceImage(image: image)
        }
    }

     func addRecipe(_ name: String){
         guard let editState = controller.editState else { return }
         if let e = RecipeUtils.addRecipe(name, filters: editState.currentEdit.filters){
             let item = Recipe(data: e)
             if let sourceImage = sourceImage {
                 item.setSourceImage(image: sourceImage)
             }
             recipes.append(item)
             controller.currentRecipe = item.data
         }
     }

     func deleteRecipe(_ index:Int){
         let result = RecipeUtils.deleteRecipe(recipes[index].data)
         if(result){
             recipes.remove(at: index)
         }
     }
    
}

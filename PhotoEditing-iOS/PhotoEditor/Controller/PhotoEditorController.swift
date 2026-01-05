import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData

class PhotoEditingController: ObservableObject {
    
    static let shared = PhotoEditingController()
    
    // MARK: - Properties
    
    // origin image: pick from gallery or camera
    private(set) var originUI: UIImage?
    // cache origin: convert from UI to CI
    private(set) var originCI: CIImage?
    // crop controller
    var cropperCtrl: CropperController = CropperController()
    // luts controller
    @NestedObservableObject
    var lutsCtrl: LutsController = LutsController()
    // recipes controller
    @NestedObservableObject
    var recipesCtrl: RecipeController = RecipeController()
    
    private(set) var editState: EditingStack?
    
    var currentEditMenu: EditMenu {
        return currentFilter.edit
    }
    
    // Image preview: will update after edited
    @Published
    var previewImage: UIImage?
    
    @Published
    var currentRecipe: RecipeObject?
    
    @Published
    var currentFilter: FilterModel = FilterModel.noneFilterModel
    
    // Check to show save recipe button
    var hasRecipeToSave: Bool {
        guard let editState = editState else { return false }
        return editState.canUndo && currentRecipe == nil
    }
    
    // Debounce mechanism
    private var filterDebounceCounter: Int = 0
    private let filterDebounceQueue = DispatchQueue(label: "com.photoediting.filterDebounce", qos: .userInitiated)
    private let filterDebounceDelay: TimeInterval = 0.3
    
    // MARK: - Initialization
    
    private init() {
        print("init PhotoEditingController")
    }
    
    deinit {
        cleanupResources()
    }
    
    // MARK: - Public Methods
    
    func setImage(image: UIImage) {
        // Reset UI
        guard lutsCtrl.loadingLut == false else {
            return
        }
        
        // Cleanup previous resources
        cleanupResources()
        
        currentFilter = FilterModel.noneFilterModel
        self.originUI = image
        self.originCI = convertUItoCI(from: image)
        
        guard let originCI = self.originCI else { return }
        
        let aspectRatio = image.size.width / image.size.height
        let previewHeight: CGFloat = 512
        let previewSize = CGSize(width: previewHeight * aspectRatio, height: previewHeight)
        
        self.editState = EditingStack(
            source: StaticImageSource(source: originCI),
            previewSize: previewSize
        )
       
        if let smallImage = resizedImage(at: originCI, scale: 128 / image.size.height, aspectRatio: 1) {
            lutsCtrl.setImage(image: smallImage)
            recipesCtrl.setImage(image: smallImage)
        }
        
        cropperCtrl = CropperController()

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.apply()
        }
    }
    
    func didReceive(action: PhotoEditingControllerAction) {
        switch action {
        case .setFilter(let closure):
            setFilterDelay(filters: closure)
            
        case .commit:
            editState?.commit()
            
        case .applyFilter(let closure):
            currentRecipe = nil
            editState?.set(filters: closure)
            editState?.commit()
            apply()
            
        case .undo:
            guard let editState = editState, editState.canUndo else { return }
            editState.undo()
            let name = editState.currentEdit.filters.colorCube?.identifier ?? ""
            lutsCtrl.selectCube(name)
            apply()

        case .revert:
            editState?.revert()
            apply()
        
        case .applyRecipe(let recipeObject):
            onApplyRecipe(recipeObject)
        }
    }
    
    // MARK: - Private Methods
    
    private func setFilterDelay(filters: @escaping (inout EditingStack.Edit.Filters) -> Void) {
        currentRecipe = nil
        
        filterDebounceQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.filterDebounceCounter += 1
            let currentCount = self.filterDebounceCounter
            
            self.editState?.set(filters: filters)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.filterDebounceDelay) { [weak self] in
                guard let self = self else { return }
                
                if self.filterDebounceCounter == currentCount {
                    self.filterDebounceCounter = 0
                    self.apply()
                } else if currentCount % 20 == 0 {
                    self.apply()
                }
            }
        }
    }
    
    private func apply() {
        guard let editState = editState,
              let preview = editState.previewImage else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let cgimg = sharedContext.createCGImage(preview, from: preview.extent) {
                self.previewImage = UIImage(cgImage: cgimg)
            }
        }
    }
    
    private func onApplyRecipe(_ data: RecipeObject) {
        let colorCube: FilterColorCube? = Data.shared.cubeBy(identifier: data.lutIdentifier ?? "")
        currentRecipe = data
        
        editState?.set(filters: RecipeUtils.applyRecipe(data, colorCube: colorCube))
        editState?.commit()
        apply()
    }
    
    private func cleanupResources() {
        previewImage = nil
        originUI = nil
        originCI = nil
        editState = nil
        filterDebounceCounter = 0
    }
}


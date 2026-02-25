import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData

class PhotoEditingController: ObservableObject {
    
    static let shared = PhotoEditingController()

    private(set) var originUI: UIImage?
    private(set) var originCI: CIImage?
    @NestedObservableObject
    var cropperCtrl: CropperController = CropperController()
    @NestedObservableObject
    var lutsCtrl: LutsController = LutsController()
    @NestedObservableObject
    var recipesCtrl: RecipeController = RecipeController()
    @NestedObservableObject
    var textCtrl: TextController = TextController()
    @NestedObservableObject
    var operationManager: EditOperationManager = EditOperationManager()
    
    private(set) var editState: EditingStack?
    private(set) var croppedEditState: EditingStack?
    
    var currentEditMenu: EditMenu {
        return currentFilter.edit
    }
    @Published
    var previewImage: UIImage?
    
    @Published
    var currentRecipe: RecipeObject?
    
    @Published
    var currentFilter: FilterModel = FilterModel.noneFilterModel

    var hasRecipeToSave: Bool {
        guard let editState = editState else { return false }
        return editState.canUndo && currentRecipe == nil
    }

    private var filterDebounceCounter: Int = 0
    private let filterDebounceQueue = DispatchQueue(label: "com.photoediting.filterDebounce", qos: .userInitiated)
    private let filterDebounceDelay: TimeInterval = 0.3

    private init() {
        print("init PhotoEditingController")
    }
    
    deinit {
        cleanupResources()
    }

    func setImage(image: UIImage) {
        guard lutsCtrl.loadingLut == false else {
            return
        }
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
        self.editState?.set(filters: { _ in })
        self.editState?.commit()
       
        if let smallImage = resizedImage(at: originCI, scale: 128 / image.size.height, aspectRatio: 1) {
            lutsCtrl.setImage(image: smallImage)
            recipesCtrl.setImage(image: smallImage)
        }
        
        cropperCtrl = CropperController()
        cropperCtrl.onCropChanged = { [weak self] in
            self?.applyCrop()
        }
        operationManager.setOriginalImage(originCI)
        operationManager.editingStack = editState
        textCtrl.operationManager = operationManager

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.apply()
        }
    }
    
    func resetCrop() {
        cropperCtrl.reset()
    }
    
    func didReceive(action: PhotoEditingControllerAction) {
        switch action {
        case .setFilter(let closure):
            setFilterDelay(filters: closure)
            
        case .commit:
            editState?.commit()
            croppedEditState?.commit()
            
        case .applyFilter(let closure):
            currentRecipe = nil
            editState?.set(filters: closure)
            editState?.commit()
            croppedEditState?.set(filters: closure)
            croppedEditState?.commit()
            if let filters = editState?.currentEdit.filters {
                addFilterOperationToStack(filters: filters)
            }
            
            apply()
            
        case .undo:
            if operationManager.canUndo {
                let lastOp = operationManager.getActiveOperations().last
                operationManager.undo()
                if let op = lastOp {
                    applyUndoForOperation(op)
                }
            }
            apply()

        case .revert:
            editState?.revert()
            croppedEditState?.revert()
            apply()
        
        case .applyRecipe(let recipeObject):
            onApplyRecipe(recipeObject)
            
        case .redo:
            if operationManager.canRedo {
                operationManager.redo()
                let currentOps = operationManager.getActiveOperations()
                
                if let lastOp = currentOps.last {
                    applyRedoForOperation(lastOp)
                }
            }
            apply()
        }
    }

    private func setFilterDelay(filters: @escaping (inout EditingStack.Edit.Filters) -> Void) {
        currentRecipe = nil
        
        filterDebounceQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.filterDebounceCounter += 1
            let currentCount = self.filterDebounceCounter
            
            self.editState?.set(filters: filters)
            self.croppedEditState?.set(filters: filters)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.filterDebounceDelay) { [weak self] in
                guard let self = self else { return }
                
                if self.filterDebounceCounter == currentCount {
                    self.filterDebounceCounter = 0
                    if let currentFilters = self.editState?.currentEdit.filters {
                        self.addFilterOperationToStack(filters: currentFilters)
                    }
                    
                    self.apply()
                } else if currentCount % 20 == 0 {
                    self.apply()
                }
            }
        }
    }
    
    private func apply() {
        let activeEditState = croppedEditState ?? editState
        
        guard let activeEditState = activeEditState,
              let preview = activeEditState.previewImage else {
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
        
        let recipeFilters = RecipeUtils.applyRecipe(data, colorCube: colorCube)
        editState?.set(filters: recipeFilters)
        editState?.commit()
        croppedEditState?.set(filters: recipeFilters)
        croppedEditState?.commit()
        apply()
    }
    
    private func applyCrop() {
        guard let originUI = originUI,
              let editState = editState else { return }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            if let cropperState = self.cropperCtrl.state,
               let croppedUIImage = originUI.cropped(withCropperState: cropperState) {
                let croppedCI = convertUItoCI(from: croppedUIImage)
                let source = StaticImageSource(source: croppedCI)
                let aspectRatio = croppedUIImage.size.width / croppedUIImage.size.height
                let previewHeight: CGFloat = 512
                let previewSize = CGSize(width: previewHeight * aspectRatio, height: previewHeight)
                
                self.croppedEditState = EditingStack(
                    source: source,
                    previewSize: previewSize
                )
                self.croppedEditState?.set(filters: { _ in })
                let currentFilters = editState.currentEdit.filters
                self.croppedEditState?.set(filters: { $0 = currentFilters })
                self.apply()
            } else {
                self.croppedEditState = nil
                self.apply()
            }
        }
    }
    
    private func cleanupResources() {
        previewImage = nil
        originUI = nil
        originCI = nil
        editState = nil
        croppedEditState = nil
        filterDebounceCounter = 0
        operationManager.clear()
        textCtrl.clearAll()
    }

    private func addFilterOperationToStack(filters: EditingStack.Edit.Filters) {
        var parameters: [String: Double] = [:]
        if let exposure = filters.exposure?.value {
            parameters["exposure"] = exposure
        }
        if let contrast = filters.contrast?.value {
            parameters["contrast"] = contrast
        }
        if let saturation = filters.saturation?.value {
            parameters["saturation"] = saturation
        }
        if let highlights = filters.highlights?.value {
            parameters["highlights"] = highlights
        }
        if let shadows = filters.shadows?.value {
            parameters["shadows"] = shadows
        }
        if let temperature = filters.temperature?.value {
            parameters["temperature"] = temperature
        }
        if let vignette = filters.vignette?.value {
            parameters["vignette"] = vignette
        }
        if let fade = filters.fade?.intensity {
            parameters["fade"] = fade
        }
        if let sharpen = filters.sharpen?.sharpness {
            parameters["sharpen"] = sharpen
        }
        if let clarity = filters.unsharpMask?.intensity {
            parameters["clarity"] = clarity
        }
        let filterName = filters.colorCube?.name ?? "Adjustment"
        let lutIdentifier = filters.colorCube?.identifier
        let activeOps = operationManager.getActiveOperations()
        if let lastOp = activeOps.last,
           let lastFilterOp = lastOp.asFilterOperation(),
           lastFilterOp.lutIdentifier == lutIdentifier,
           Date().timeIntervalSince(lastOp.timestamp) < 2.0 {
            operationManager.removeOperation(id: lastOp.id)
        }
        
        let filterOp = FilterOperation(
            filterName: filterName,
            lutIdentifier: lutIdentifier,
            intensity: 1.0,
            parameters: parameters
        )
        
        operationManager.addOperation(filterOp)
    }

    private func applyUndoForOperation(_ operation: AnyEditOperation) {
        switch operation.type {
        case .text:
            textCtrl.syncWithOperationStack()
        case .filter, .adjustment:
            rebuildFiltersFromOperations()
            
        default:
            break
        }
    }

    private func applyRedoForOperation(_ operation: AnyEditOperation) {
        switch operation.type {
        case .text:
            textCtrl.syncWithOperationStack()
        case .filter, .adjustment:
            rebuildFiltersFromOperations()
            
        default:
            break
        }
    }

    private func rebuildFiltersFromOperations() {
        let activeOps = operationManager.getActiveOperations()
        editState?.revert()
        croppedEditState?.revert()
        for op in activeOps {
            switch op.type {
            case .filter:
                if let filterOp = op.asFilterOperation() {
                    applyFilterOperation(filterOp)
                }
            case .adjustment:
                if let adjOp = op.asAdjustmentOperation() {
                    applyAdjustmentOperation(adjOp)
                }
            case .text:
                break
            default:
                break
            }
        }
        
        editState?.commit()
        croppedEditState?.commit()
        let lastFilterOp = activeOps.reversed().first(where: { $0.type == .filter })
        if let lutId = lastFilterOp?.asFilterOperation()?.lutIdentifier {
            lutsCtrl.selectCube(lutId)
        }
        textCtrl.syncWithOperationStack()
    }
    
    private func applyFiltersToBoth(_ closure: @escaping (inout EditingStack.Edit.Filters) -> Void) {
        editState?.set(filters: closure)
        croppedEditState?.set(filters: closure)
    }
    
    private func makeFilterClosure(from operation: FilterOperation) -> (inout EditingStack.Edit.Filters) -> Void {
        return { filters in
            if let lutId = operation.lutIdentifier,
               let cube = Data.shared.cubeBy(identifier: lutId) {
                filters.colorCube = cube
            }
            if let exposure = operation.parameters["exposure"] {
                var filter = FilterExposure()
                filter.value = exposure
                filters.exposure = filter
            }
            if let contrast = operation.parameters["contrast"] {
                var filter = FilterContrast()
                filter.value = contrast
                filters.contrast = filter
            }
            if let saturation = operation.parameters["saturation"] {
                var filter = FilterSaturation()
                filter.value = saturation
                filters.saturation = filter
            }
            if let highlights = operation.parameters["highlights"] {
                var filter = FilterHighlights()
                filter.value = highlights
                filters.highlights = filter
            }
            if let shadows = operation.parameters["shadows"] {
                var filter = FilterShadows()
                filter.value = shadows
                filters.shadows = filter
            }
            if let temperature = operation.parameters["temperature"] {
                var filter = FilterTemperature()
                filter.value = temperature
                filters.temperature = filter
            }
            if let vignette = operation.parameters["vignette"] {
                var filter = FilterVignette()
                filter.value = vignette
                filters.vignette = filter
            }
            if let fade = operation.parameters["fade"] {
                var filter = FilterFade()
                filter.intensity = fade
                filters.fade = filter
            }
            if let sharpen = operation.parameters["sharpen"] {
                var filter = FilterSharpen()
                filter.sharpness = sharpen
                filters.sharpen = filter
            }
            if let clarity = operation.parameters["clarity"] {
                var filter = FilterUnsharpMask()
                filter.intensity = clarity
                filter.radius = 0.12
                filters.unsharpMask = filter
            }
        }
    }
    
    private func makeFilterClosure(from operation: AdjustmentOperation) -> (inout EditingStack.Edit.Filters) -> Void {
        return { filters in
            switch operation.adjustmentType {
            case .exposure:
                var filter = FilterExposure()
                filter.value = operation.value
                filters.exposure = filter
            case .contrast:
                var filter = FilterContrast()
                filter.value = operation.value
                filters.contrast = filter
            case .saturation:
                var filter = FilterSaturation()
                filter.value = operation.value
                filters.saturation = filter
            case .highlights:
                var filter = FilterHighlights()
                filter.value = operation.value
                filters.highlights = filter
            case .shadows:
                var filter = FilterShadows()
                filter.value = operation.value
                filters.shadows = filter
            case .temperature:
                var filter = FilterTemperature()
                filter.value = operation.value
                filters.temperature = filter
            case .vignette:
                var filter = FilterVignette()
                filter.value = operation.value
                filters.vignette = filter
            case .sharpen:
                var filter = FilterSharpen()
                filter.sharpness = operation.value
                filters.sharpen = filter
            case .clarity:
                var filter = FilterUnsharpMask()
                filter.intensity = operation.value
                filter.radius = 0.12
                filters.unsharpMask = filter
            default:
                break
            }
        }
    }
    
    private func applyFilterOperation(_ operation: FilterOperation) {
        applyFiltersToBoth(makeFilterClosure(from: operation))
    }
    
    private func applyAdjustmentOperation(_ operation: AdjustmentOperation) {
        applyFiltersToBoth(makeFilterClosure(from: operation))
    }
}


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
    @NestedObservableObject
    var cropperCtrl: CropperController = CropperController()
    // luts controller
    @NestedObservableObject
    var lutsCtrl: LutsController = LutsController()
    // recipes controller
    @NestedObservableObject
    var recipesCtrl: RecipeController = RecipeController()
    // text controller
    @NestedObservableObject
    var textCtrl: TextController = TextController()
    
    // operation manager for undo/redo
    @NestedObservableObject
    var operationManager: EditOperationManager = EditOperationManager()
    
    private(set) var editState: EditingStack?
    private(set) var croppedEditState: EditingStack?
    
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
        
        // Initialize with default filters to avoid empty edits array
        self.editState?.set(filters: { _ in })
        self.editState?.commit()
       
        if let smallImage = resizedImage(at: originCI, scale: 128 / image.size.height, aspectRatio: 1) {
            lutsCtrl.setImage(image: smallImage)
            recipesCtrl.setImage(image: smallImage)
        }
        
        cropperCtrl = CropperController()
        // Set up callback to update preview when crop changes
        cropperCtrl.onCropChanged = { [weak self] in
            self?.applyCrop()
        }
        
        // Setup operation manager for text operations
        operationManager.setOriginalImage(originCI)
        operationManager.editingStack = editState
        
        // Link text controller to operation manager
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
            
            // Add filter operation to the stack
            if let filters = editState?.currentEdit.filters {
                addFilterOperationToStack(filters: filters)
            }
            
            apply()
            
        case .undo:
            // Unified undo for all operations
            if operationManager.canUndo {
                let lastOp = operationManager.getActiveOperations().last
                operationManager.undo()
                
                // Apply appropriate action based on operation type
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
            // Unified redo for all operations
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
    
    // MARK: - Private Methods
    
    private func setFilterDelay(filters: @escaping (inout EditingStack.Edit.Filters) -> Void) {
        currentRecipe = nil
        
        filterDebounceQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.filterDebounceCounter += 1
            let currentCount = self.filterDebounceCounter
            
            self.editState?.set(filters: filters)
            // Also apply to cropped state if it exists
            self.croppedEditState?.set(filters: filters)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.filterDebounceDelay) { [weak self] in
                guard let self = self else { return }
                
                if self.filterDebounceCounter == currentCount {
                    self.filterDebounceCounter = 0
                    
                    // Add filter operation to stack when debounce completes
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
        // Use cropped edit state if crop is applied, otherwise use original
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
                // Create new editing stack with cropped image
                let croppedCI = convertUItoCI(from: croppedUIImage)
                let source = StaticImageSource(source: croppedCI)
                
                // Create a new EditingStack with the cropped image
                let aspectRatio = croppedUIImage.size.width / croppedUIImage.size.height
                let previewHeight: CGFloat = 512
                let previewSize = CGSize(width: previewHeight * aspectRatio, height: previewHeight)
                
                self.croppedEditState = EditingStack(
                    source: source,
                    previewSize: previewSize
                )
                
                // Initialize with default filters first to avoid empty edits array
                self.croppedEditState?.set(filters: { _ in })
                
                // Copy current filters to cropped edit state
                let currentFilters = editState.currentEdit.filters
                self.croppedEditState?.set(filters: { $0 = currentFilters })
                
                // Apply with cropped image
                self.apply()
            } else {
                // No crop applied, use original editState
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
        
        // Clear operation manager and text controller
        operationManager.clear()
        textCtrl.clearAll()
    }
    
    // MARK: - Operation Stack Helpers
    
    /// Add filter operation to the stack
    private func addFilterOperationToStack(filters: EditingStack.Edit.Filters) {
        var parameters: [String: Double] = [:]
        
        // Extract filter parameters
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
        
        // Create filter operation
        let filterName = filters.colorCube?.name ?? "Adjustment"
        let lutIdentifier = filters.colorCube?.identifier
        
        // Check if last operation was a filter with same LUT
        // If so, and it was recent (within 2 seconds), replace it instead of adding new one
        let activeOps = operationManager.getActiveOperations()
        if let lastOp = activeOps.last,
           let lastFilterOp = lastOp.asFilterOperation(),
           lastFilterOp.lutIdentifier == lutIdentifier,
           Date().timeIntervalSince(lastOp.timestamp) < 2.0 {
            // Remove last operation and add updated one
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
    
    /// Apply undo for specific operation type
    private func applyUndoForOperation(_ operation: AnyEditOperation) {
        switch operation.type {
        case .text:
            // Sync text controller with operation stack
            textCtrl.syncWithOperationStack()
            
        case .filter, .adjustment:
            // Rebuild filter state from remaining operations
            rebuildFiltersFromOperations()
            
        default:
            break
        }
    }
    
    /// Apply redo for specific operation type
    private func applyRedoForOperation(_ operation: AnyEditOperation) {
        switch operation.type {
        case .text:
            // Sync text controller with operation stack
            textCtrl.syncWithOperationStack()
            
        case .filter, .adjustment:
            // Rebuild filter state from all operations
            rebuildFiltersFromOperations()
            
        default:
            break
        }
    }
    
    /// Rebuild filters and text from operation stack
    private func rebuildFiltersFromOperations() {
        let activeOps = operationManager.getActiveOperations()
        
        // Reset to base state
        editState?.revert()
        croppedEditState?.revert()
        
        // Reapply all operations in order
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
                // Text is handled separately via textCtrl.syncWithOperationStack()
                break
            default:
                break
            }
        }
        
        editState?.commit()
        croppedEditState?.commit()
        
        // Update UI - find last filter operation
        let lastFilterOp = activeOps.reversed().first(where: { $0.type == .filter })
        if let lutId = lastFilterOp?.asFilterOperation()?.lutIdentifier {
            lutsCtrl.selectCube(lutId)
        }
        
        // Sync text elements
        textCtrl.syncWithOperationStack()
    }
    
    /// Apply a single filter operation
    private func applyFilterOperation(_ operation: FilterOperation) {
        editState?.set(filters: { filters in
            // Apply LUT if present
            if let lutId = operation.lutIdentifier,
               let cube = Data.shared.cubeBy(identifier: lutId) {
                filters.colorCube = cube
            }
            
            // Apply adjustment parameters using PixelEngine's filter types
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
        })
        
        // Apply to cropped state too
        croppedEditState?.set(filters: { filters in
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
        })
    }
    
    /// Apply a single adjustment operation
    private func applyAdjustmentOperation(_ operation: AdjustmentOperation) {
        editState?.set(filters: { filters in
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
        })
        
        croppedEditState?.set(filters: { filters in
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
        })
    }
}


import SwiftUI
import PixelEnginePackage

// MARK: - Filter Control Configuration Protocol

protocol FilterControlConfiguration {
    associatedtype FilterType
    
    var range: (min: Double, max: Double) { get }
    var defaultValue: Double { get }
    var rangeDisplay: (min: Double, max: Double)? { get }
    var label: String? { get }
    var spacing: CGFloat? { get }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double?
    func createFilter(value: Double) -> FilterType
    func applyFilter(_ filter: FilterType?, to filters: inout EditingStack.Edit.Filters)
}

extension FilterControlConfiguration {
    var spacing: CGFloat? { nil }
}

// MARK: - Generic Filter Control

struct GenericFilterControl<Config: FilterControlConfiguration>: View {
    let config: Config
    @State private var filterIntensity: Double = 0
    
    var body: some View {
        let intensity = Binding<Double>(
            get: { self.filterIntensity },
            set: {
                self.filterIntensity = $0
                self.valueChanged()
            }
        )
        
        return FilterSlider(
            value: intensity,
            range: config.range,
            lable: config.label ?? "",
            defaultValue: config.defaultValue,
            rangeDisplay: config.rangeDisplay ?? (-100, 100),
            spacing: config.spacing ?? 4
        )
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    private func didReceiveCurrentEdit() {
        guard let edit = PhotoEditingController.shared.editState?.currentEdit else { return }
        self.filterIntensity = config.getCurrentValue(from: edit.filters) ?? config.defaultValue
    }
    
    private func valueChanged() {
        let value = self.filterIntensity
        
        guard value != config.defaultValue else {
            PhotoEditingController.shared.didReceive(
                action: PhotoEditingControllerAction.setFilter({ config.applyFilter(nil, to: &$0) })
            )
            return
        }
        
        let filter = config.createFilter(value: value)
        PhotoEditingController.shared.didReceive(
            action: PhotoEditingControllerAction.setFilter({ config.applyFilter(filter, to: &$0) })
        )
    }
}

// MARK: - Concrete Configurations

struct ExposureConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterExposure.range.min, FilterExposure.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { nil }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.exposure?.value
    }
    
    func createFilter(value: Double) -> FilterExposure {
        var filter = FilterExposure()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterExposure?, to filters: inout EditingStack.Edit.Filters) {
        filters.exposure = filter
    }
}

struct ContrastConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterContrast.range.min, FilterContrast.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { nil }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.contrast?.value
    }
    
    func createFilter(value: Double) -> FilterContrast {
        var filter = FilterContrast()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterContrast?, to filters: inout EditingStack.Edit.Filters) {
        filters.contrast = filter
    }
}

struct SaturationConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterSaturation.range.min, FilterSaturation.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { nil }
    var label: String? { "Saturation" }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.saturation?.value
    }
    
    func createFilter(value: Double) -> FilterSaturation {
        var filter = FilterSaturation()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterSaturation?, to filters: inout EditingStack.Edit.Filters) {
        filters.saturation = filter
    }
}

struct HighlightsConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterHighlights.range.min, FilterHighlights.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)?
    var label: String?
    var spacing: CGFloat?
    
    init(withLabel label: String? = nil, withRangeDisplay rangeDisplay: (min: Double, max: Double)? = (0, 100), spacing: CGFloat? = nil) {
        self.label = label
        self.rangeDisplay = rangeDisplay
        self.spacing = spacing
    }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.highlights?.value
    }
    
    func createFilter(value: Double) -> FilterHighlights {
        var filter = FilterHighlights()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterHighlights?, to filters: inout EditingStack.Edit.Filters) {
        filters.highlights = filter
    }
}

struct ShadowsConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterShadows.range.min, FilterShadows.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)?
    var label: String?
    var spacing: CGFloat?
    
    init(withLabel label: String? = nil, withRangeDisplay rangeDisplay: (min: Double, max: Double)? = nil, spacing: CGFloat? = nil) {
        self.label = label
        self.rangeDisplay = rangeDisplay
        self.spacing = spacing
    }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.shadows?.value
    }
    
    func createFilter(value: Double) -> FilterShadows {
        var filter = FilterShadows()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterShadows?, to filters: inout EditingStack.Edit.Filters) {
        filters.shadows = filter
    }
}

struct TemperatureConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterTemperature.range.min, FilterTemperature.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { nil }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.temperature?.value
    }
    
    func createFilter(value: Double) -> FilterTemperature {
        var filter = FilterTemperature()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterTemperature?, to filters: inout EditingStack.Edit.Filters) {
        filters.temperature = filter
    }
}

struct GaussianBlurConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterGaussianBlur.range.min, FilterGaussianBlur.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { nil }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.gaussianBlur?.value
    }
    
    func createFilter(value: Double) -> FilterGaussianBlur {
        var filter = FilterGaussianBlur()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterGaussianBlur?, to filters: inout EditingStack.Edit.Filters) {
        filters.gaussianBlur = filter
    }
}

struct FadeConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (0, 1) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { (0, 100) }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.fade?.intensity
    }
    
    func createFilter(value: Double) -> FilterFade {
        var filter = FilterFade()
        filter.intensity = value
        return filter
    }
    
    func applyFilter(_ filter: FilterFade?, to filters: inout EditingStack.Edit.Filters) {
        filters.fade = filter
    }
}

struct ClarityConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (0, 1) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { (0, 100) }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.unsharpMask?.intensity
    }
    
    func createFilter(value: Double) -> FilterUnsharpMask {
        var filter = FilterUnsharpMask()
        filter.intensity = value
        filter.radius = 0.12
        return filter
    }
    
    func applyFilter(_ filter: FilterUnsharpMask?, to filters: inout EditingStack.Edit.Filters) {
        filters.unsharpMask = filter
    }
}

struct SharpenConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (0, 1) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { (0, 100) }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.sharpen?.sharpness
    }
    
    func createFilter(value: Double) -> FilterSharpen {
        var filter = FilterSharpen()
        filter.sharpness = value
        return filter
    }
    
    func applyFilter(_ filter: FilterSharpen?, to filters: inout EditingStack.Edit.Filters) {
        filters.sharpen = filter
    }
}

struct VignetteConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterVignette.range.min, FilterVignette.range.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { nil }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.vignette?.value
    }
    
    func createFilter(value: Double) -> FilterVignette {
        var filter = FilterVignette()
        filter.value = value
        return filter
    }
    
    func applyFilter(_ filter: FilterVignette?, to filters: inout EditingStack.Edit.Filters) {
        filters.vignette = filter
    }
}

struct ColorConfiguration: FilterControlConfiguration {
    var range: (min: Double, max: Double) { (FilterColor.rangeBrightness.min, FilterColor.rangeBrightness.max) }
    var defaultValue: Double { 0 }
    var rangeDisplay: (min: Double, max: Double)? { nil }
    var label: String? { nil }
    
    func getCurrentValue(from filters: EditingStack.Edit.Filters) -> Double? {
        filters.color?.valueBrightness
    }
    
    func createFilter(value: Double) -> FilterColor {
        var filter = FilterColor()
        filter.valueBrightness = value
        return filter
    }
    
    func applyFilter(_ filter: FilterColor?, to filters: inout EditingStack.Edit.Filters) {
        filters.color = filter
    }
}


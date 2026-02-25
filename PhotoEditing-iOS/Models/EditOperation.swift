import Foundation
import SwiftUI
import CoreImage

public protocol EditOperation: Codable, Identifiable {
    var id: UUID { get }
    var type: EditOperationType { get }
    var timestamp: Date { get }
    func apply(to image: CIImage) -> CIImage
    var description: String { get }
    var isReversible: Bool { get }
}

public enum EditOperationType: String, Codable {
    case filter
    case text
    case sticker
    case drawing
    case adjustment
    case blur
    case crop
    case rotate
    case flip
    case custom
}

public struct FilterOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .filter
    public let timestamp: Date
    public var filterName: String
    public var lutIdentifier: String?
    public var intensity: Double
    public var parameters: [String: Double]
    
    public var description: String {
        return "Фильтр: \(filterName)"
    }
    
    public var isReversible: Bool { true }
    
    public init(filterName: String, 
         lutIdentifier: String? = nil,
         intensity: Double = 1.0,
         parameters: [String: Double] = [:]) {
        self.id = UUID()
        self.timestamp = Date()
        self.filterName = filterName
        self.lutIdentifier = lutIdentifier
        self.intensity = intensity
        self.parameters = parameters
    }
    
    public func apply(to image: CIImage) -> CIImage {
        return image
    }
}

public struct TextOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .text
    public let timestamp: Date
    public var text: String
    public var position: CGPoint
    public var fontSize: CGFloat
    public var fontName: String
    public var color: CodableColor
    public var rotation: Double
    public var scale: Double
    public var alignment: TextAlignment
    public var isBold: Bool
    public var isItalic: Bool
    public var textElementId: UUID
    
    public var description: String {
        return "Текст: \(text.prefix(20))..."
    }
    
    public var isReversible: Bool { true }
    
    public init(text: String,
         position: CGPoint = .zero,
         fontSize: CGFloat = 24,
         fontName: String = "System",
         color: Color = .white,
         rotation: Double = 0,
         scale: Double = 1.0,
         alignment: TextAlignment = .center,
         isBold: Bool = false,
         isItalic: Bool = false,
         textElementId: UUID? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.text = text
        self.position = position
        self.fontSize = fontSize
        self.fontName = fontName
        self.color = CodableColor(color: color)
        self.rotation = rotation
        self.scale = scale
        self.alignment = alignment
        self.isBold = isBold
        self.isItalic = isItalic
        self.textElementId = textElementId ?? UUID()
    }
    
    public func apply(to image: CIImage) -> CIImage {
        return image
    }
}

public struct StickerOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .sticker
    public let timestamp: Date
    public var stickerIdentifier: String
    public var imageName: String
    public var position: CGPoint
    public var size: CGSize
    public var rotation: Double
    public var scale: Double
    public var opacity: Double
    
    public var description: String {
        return "Стикер: \(stickerIdentifier)"
    }
    
    public var isReversible: Bool { true }
    
    public init(stickerIdentifier: String,
         imageName: String,
         position: CGPoint = .zero,
         size: CGSize = CGSize(width: 100, height: 100),
         rotation: Double = 0,
         scale: Double = 1.0,
         opacity: Double = 1.0) {
        self.id = UUID()
        self.timestamp = Date()
        self.stickerIdentifier = stickerIdentifier
        self.imageName = imageName
        self.position = position
        self.size = size
        self.rotation = rotation
        self.scale = scale
        self.opacity = opacity
    }
    
    public func apply(to image: CIImage) -> CIImage {
        return image
    }
}

public struct AdjustmentOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .adjustment
    public let timestamp: Date
    public var adjustmentType: AdjustmentType
    public var value: Double
    
    public var description: String {
        return "\(adjustmentType.displayName): \(Int(value))"
    }
    
    public var isReversible: Bool { true }
    
    public init(adjustmentType: AdjustmentType, value: Double) {
        self.id = UUID()
        self.timestamp = Date()
        self.adjustmentType = adjustmentType
        self.value = value
    }
    
    public func apply(to image: CIImage) -> CIImage {
        switch adjustmentType {
        case .exposure:
            return image.applyingFilter("CIExposureAdjust", parameters: ["inputEV": value])
        case .contrast:
            return image.applyingFilter("CIColorControls", parameters: ["inputContrast": value])
        case .saturation:
            return image.applyingFilter("CIColorControls", parameters: ["inputSaturation": value])
        case .brightness:
            return image.applyingFilter("CIColorControls", parameters: ["inputBrightness": value])
        case .temperature:
            return image.applyingFilter("CITemperatureAndTint", parameters: ["inputNeutral": CIVector(x: value, y: 0)])
        case .highlights, .shadows, .vignette, .sharpen, .blur, .clarity:
            return image
        }
    }
}

public enum AdjustmentType: String, Codable {
    case exposure
    case contrast
    case saturation
    case brightness
    case temperature
    case highlights
    case shadows
    case vignette
    case sharpen
    case blur
    case clarity
    
    var displayName: String {
        switch self {
        case .exposure: return "Экспозиция"
        case .contrast: return "Контраст"
        case .saturation: return "Насыщенность"
        case .brightness: return "Яркость"
        case .temperature: return "Температура"
        case .highlights: return "Света"
        case .shadows: return "Тени"
        case .vignette: return "Виньетка"
        case .sharpen: return "Резкость"
        case .blur: return "Размытие"
        case .clarity: return "Четкость"
        }
    }
}

public struct CodableColor: Codable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    public var color: Color {
        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

public enum TextAlignment: String, Codable {
    case left
    case center
    case right
}


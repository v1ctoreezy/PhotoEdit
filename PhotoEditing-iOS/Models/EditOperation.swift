import Foundation
import SwiftUI
import CoreImage

// MARK: - Base Protocol

/// Базовый протокол для всех операций редактирования
public protocol EditOperation: Codable, Identifiable {
    var id: UUID { get }
    var type: EditOperationType { get }
    var timestamp: Date { get }
    
    /// Применить операцию к изображению
    func apply(to image: CIImage) -> CIImage
    
    /// Получить описание операции для UI
    var description: String { get }
    
    /// Можно ли отменить эту операцию
    var isReversible: Bool { get }
}

// MARK: - Operation Types

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

// MARK: - Filter Operation

/// Операция применения фильтра
public struct FilterOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .filter
    public let timestamp: Date
    
    // Filter-specific properties
    public var filterName: String
    public var lutIdentifier: String?
    public var intensity: Double
    public var parameters: [String: Double] // для хранения параметров типа exposure, contrast, etc.
    
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
        // Здесь применяем фильтр через PixelEngine или Core Image
        // Это интеграция с существующей системой фильтров
        return image
    }
}

// MARK: - Text Operation

/// Операция добавления текста
public struct TextOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .text
    public let timestamp: Date
    
    // Text-specific properties
    public var text: String
    public var position: CGPoint
    public var fontSize: CGFloat
    public var fontName: String
    public var color: CodableColor
    public var rotation: Double
    public var scale: Double
    public var alignment: TextAlignment
    
    public var description: String {
        return "Текст: \(text.prefix(20))..."
    }
    
    public var isReversible: Bool { true }
    
    public init(text: String,
         position: CGPoint = .zero,
         fontSize: CGFloat = 24,
         fontName: String = "Helvetica",
         color: Color = .white,
         rotation: Double = 0,
         scale: Double = 1.0,
         alignment: TextAlignment = .center) {
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
    }
    
    public func apply(to image: CIImage) -> CIImage {
        // Применяем текст поверх изображения
        // Можно использовать UIGraphicsImageRenderer для рендеринга текста
        return image
    }
}

// MARK: - Sticker Operation

/// Операция добавления стикера
public struct StickerOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .sticker
    public let timestamp: Date
    
    // Sticker-specific properties
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
        // Накладываем стикер на изображение
        return image
    }
}

// MARK: - Adjustment Operation

/// Операция регулировки параметров (яркость, контраст, насыщенность и т.д.)
public struct AdjustmentOperation: EditOperation {
    public let id: UUID
    public let type: EditOperationType = .adjustment
    public let timestamp: Date
    
    // Adjustment parameters
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
        // Применяем соответствующий Core Image фильтр
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
            // Для более сложных операций нужна дополнительная логика
            return image
        }
    }
}

// MARK: - Adjustment Types

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

// MARK: - Helper Types

/// Обёртка для Color, чтобы сделать его Codable
public struct CodableColor: Codable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double
    
    public init(color: Color) {
        // Извлекаем компоненты цвета
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


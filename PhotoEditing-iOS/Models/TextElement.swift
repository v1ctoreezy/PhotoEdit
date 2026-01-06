import Foundation
import SwiftUI

struct TextElement: Identifiable, Codable {
    let id: UUID
    var text: String
    var position: CGPoint
    var color: Color
    var fontSize: CGFloat
    var fontName: String
    var isBold: Bool
    var isItalic: Bool
    
    init(
        id: UUID = UUID(),
        text: String = "Текст",
        position: CGPoint = .zero,
        color: Color = .white,
        fontSize: CGFloat = 24,
        fontName: String = "System",
        isBold: Bool = false,
        isItalic: Bool = false
    ) {
        self.id = id
        self.text = text
        self.position = position
        self.color = color
        self.fontSize = fontSize
        self.fontName = fontName
        self.isBold = isBold
        self.isItalic = isItalic
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, text, position, fontSize, fontName, isBold, isItalic
        case colorRed, colorGreen, colorBlue, colorOpacity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        
        let x = try container.decode(CGFloat.self, forKey: .position)
        let y = try container.decode(CGFloat.self, forKey: .position)
        position = CGPoint(x: x, y: y)
        
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        fontName = try container.decode(String.self, forKey: .fontName)
        isBold = try container.decodeIfPresent(Bool.self, forKey: .isBold) ?? false
        isItalic = try container.decodeIfPresent(Bool.self, forKey: .isItalic) ?? false
        
        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let opacity = try container.decode(Double.self, forKey: .colorOpacity)
        
        color = Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(position.x, forKey: .position)
        try container.encode(position.y, forKey: .position)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(fontName, forKey: .fontName)
        try container.encode(isBold, forKey: .isBold)
        try container.encode(isItalic, forKey: .isItalic)
        
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        try container.encode(Double(red), forKey: .colorRed)
        try container.encode(Double(green), forKey: .colorGreen)
        try container.encode(Double(blue), forKey: .colorBlue)
        try container.encode(Double(alpha), forKey: .colorOpacity)
    }
    
    // MARK: - Font Helper
    
    func getFont() -> Font {
        var font: Font
        
        switch fontName {
        case "System":
            font = .system(size: fontSize)
        case "Helvetica":
            font = .custom("Helvetica", size: fontSize)
        case "Arial":
            font = .custom("Arial", size: fontSize)
        case "Courier":
            font = .custom("Courier", size: fontSize)
        case "Georgia":
            font = .custom("Georgia", size: fontSize)
        case "Times New Roman":
            font = .custom("Times New Roman", size: fontSize)
        case "Verdana":
            font = .custom("Verdana", size: fontSize)
        default:
            font = .system(size: fontSize)
        }
        
        // Apply bold and italic
        if isBold && isItalic {
            font = font.weight(.bold).italic()
        } else if isBold {
            font = font.weight(.bold)
        } else if isItalic {
            font = font.italic()
        }
        
        return font
    }
}


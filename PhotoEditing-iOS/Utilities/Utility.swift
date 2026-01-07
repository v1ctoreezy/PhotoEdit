import Foundation
import UIKit
import CoreImage
import SwiftUI

let sharedContext = CIContext(options: [.useSoftwareRenderer : false])

func resizedImage(at image: CIImage, scale: CGFloat, aspectRatio: CGFloat) -> CIImage? {
    
    let filter = CIFilter(name: "CILanczosScaleTransform")
    filter?.setValue(image, forKey: kCIInputImageKey)
    filter?.setValue(scale, forKey: kCIInputScaleKey)
    filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
    
    return filter?.outputImage
}

func convertUItoCI(from:UIImage) -> CIImage{
    let image = CIImage(image: from)!
    let fixedOriantationImage = image.oriented(forExifOrientation: imageOrientationToTiffOrientation(from.imageOrientation))
    return fixedOriantationImage
}

func imageOrientationToTiffOrientation(_ value: UIImage.Orientation) -> Int32 {
  switch value{
  case .up:
    return 1
  case .down:
    return 3
  case .left:
    return 8
  case .right:
    return 6
  case .upMirrored:
    return 2
  case .downMirrored:
    return 4
  case .leftMirrored:
    return 5
  case .rightMirrored:
    return 7
  default:
    return 1
  }
}

// MARK: - UIImage + Text Rendering

extension UIImage {
    /// Render text elements on top of the image
    func withTextElements(_ textElements: [TextElement]) -> UIImage {
        guard !textElements.isEmpty else { return self }
        
        let imageSize = self.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { context in
            // Draw the original image
            self.draw(in: CGRect(origin: .zero, size: imageSize))
            
            // Draw each text element
            for textElement in textElements {
                // Convert normalized position (0-1) to actual pixel coordinates
                let x = textElement.position.x * imageSize.width
                let y = textElement.position.y * imageSize.height
                
                // Get UIFont from text element
                let uiFont = getUIFont(for: textElement)
                
                // Convert SwiftUI Color to UIColor
                let uiColor = UIColor(textElement.color)
                
                // Create shadow for better readability
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
                shadow.shadowBlurRadius = 2
                shadow.shadowOffset = CGSize(width: 0, height: 1)
                
                // Set text attributes
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: uiFont,
                    .foregroundColor: uiColor,
                    .shadow: shadow
                ]
                
                let attributedString = NSAttributedString(string: textElement.text, attributes: attributes)
                
                // Calculate text size
                let textSize = attributedString.size()
                
                // Center the text at the position
                let textRect = CGRect(
                    x: x - textSize.width / 2,
                    y: y - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                // Draw the text
                attributedString.draw(in: textRect)
            }
        }
    }
    
    /// Helper to convert TextElement font properties to UIFont
    private func getUIFont(for textElement: TextElement) -> UIFont {
        var font: UIFont
        
        switch textElement.fontName {
        case "System":
            font = .systemFont(ofSize: textElement.fontSize)
        case "Helvetica":
            font = UIFont(name: "Helvetica", size: textElement.fontSize) ?? .systemFont(ofSize: textElement.fontSize)
        case "Arial":
            font = UIFont(name: "Arial", size: textElement.fontSize) ?? .systemFont(ofSize: textElement.fontSize)
        case "Courier":
            font = UIFont(name: "Courier", size: textElement.fontSize) ?? .systemFont(ofSize: textElement.fontSize)
        case "Georgia":
            font = UIFont(name: "Georgia", size: textElement.fontSize) ?? .systemFont(ofSize: textElement.fontSize)
        case "Times New Roman":
            font = UIFont(name: "TimesNewRomanPSMT", size: textElement.fontSize) ?? .systemFont(ofSize: textElement.fontSize)
        case "Verdana":
            font = UIFont(name: "Verdana", size: textElement.fontSize) ?? .systemFont(ofSize: textElement.fontSize)
        default:
            font = .systemFont(ofSize: textElement.fontSize)
        }
        
        // Apply bold and italic
        if textElement.isBold && textElement.isItalic {
            let descriptor = font.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
            if let newDescriptor = descriptor {
                font = UIFont(descriptor: newDescriptor, size: textElement.fontSize)
            }
        } else if textElement.isBold {
            let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
            if let newDescriptor = descriptor {
                font = UIFont(descriptor: newDescriptor, size: textElement.fontSize)
            }
        } else if textElement.isItalic {
            let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic)
            if let newDescriptor = descriptor {
                font = UIFont(descriptor: newDescriptor, size: textElement.fontSize)
            }
        }
        
        return font
    }
}

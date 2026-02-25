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

extension UIImage {
    func withTextElements(_ textElements: [TextElement], previewHeight: CGFloat = 512) -> UIImage {
        guard !textElements.isEmpty else { return self }
        let imageSize = self.size
        let scaleFactor = imageSize.height / previewHeight
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: imageSize))
            for textElement in textElements {
                let x = textElement.position.x * imageSize.width
                let y = textElement.position.y * imageSize.height
                let scaledFontSize = textElement.fontSize * scaleFactor
                let uiFont = getUIFont(for: textElement, scaledFontSize: scaledFontSize)
                let uiColor = UIColor(textElement.color)
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
                shadow.shadowBlurRadius = 2 * scaleFactor
                shadow.shadowOffset = CGSize(width: 0, height: 1 * scaleFactor)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: uiFont,
                    .foregroundColor: uiColor,
                    .shadow: shadow
                ]
                
                let attributedString = NSAttributedString(string: textElement.text, attributes: attributes)
                let textSize = attributedString.size()
                var textX = x - textSize.width / 2
                var textY = y - textSize.height / 2
                let edgePadding: CGFloat = 10 * scaleFactor
                textX = max(edgePadding, textX)
                textX = min(imageSize.width - textSize.width - edgePadding, textX)
                textY = max(edgePadding, textY)
                textY = min(imageSize.height - textSize.height - edgePadding, textY)
                if textSize.width > imageSize.width - 2 * edgePadding {
                    textX = (imageSize.width - textSize.width) / 2
                }
                if textSize.height > imageSize.height - 2 * edgePadding {
                    textY = (imageSize.height - textSize.height) / 2
                }
                
                let textRect = CGRect(
                    x: textX,
                    y: textY,
                    width: textSize.width,
                    height: textSize.height
                )
                attributedString.draw(in: textRect)
            }
        }
    }

    private func getUIFont(for textElement: TextElement, scaledFontSize: CGFloat) -> UIFont {
        var font: UIFont
        
        switch textElement.fontName {
        case "System":
            font = .systemFont(ofSize: scaledFontSize)
        case "Helvetica":
            font = UIFont(name: "Helvetica", size: scaledFontSize) ?? .systemFont(ofSize: scaledFontSize)
        case "Arial":
            font = UIFont(name: "Arial", size: scaledFontSize) ?? .systemFont(ofSize: scaledFontSize)
        case "Courier":
            font = UIFont(name: "Courier", size: scaledFontSize) ?? .systemFont(ofSize: scaledFontSize)
        case "Georgia":
            font = UIFont(name: "Georgia", size: scaledFontSize) ?? .systemFont(ofSize: scaledFontSize)
        case "Times New Roman":
            font = UIFont(name: "TimesNewRomanPSMT", size: scaledFontSize) ?? .systemFont(ofSize: scaledFontSize)
        case "Verdana":
            font = UIFont(name: "Verdana", size: scaledFontSize) ?? .systemFont(ofSize: scaledFontSize)
        default:
            font = .systemFont(ofSize: scaledFontSize)
        }
        if textElement.isBold && textElement.isItalic {
            let descriptor = font.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
            if let newDescriptor = descriptor {
                font = UIFont(descriptor: newDescriptor, size: scaledFontSize)
            }
        } else if textElement.isBold {
            let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
            if let newDescriptor = descriptor {
                font = UIFont(descriptor: newDescriptor, size: scaledFontSize)
            }
        } else if textElement.isItalic {
            let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic)
            if let newDescriptor = descriptor {
                font = UIFont(descriptor: newDescriptor, size: scaledFontSize)
            }
        }
        
        return font
    }
}

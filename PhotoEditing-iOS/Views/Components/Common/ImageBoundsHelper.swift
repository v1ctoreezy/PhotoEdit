import SwiftUI

/// Helper to calculate the actual bounds of an image when displayed with aspectRatio(.fit)
struct ImageBounds {
    let frame: CGRect
    let size: CGSize
    
    var width: CGSize {
        return frame.size
    }
    
    var offset: CGPoint {
        return CGPoint(x: frame.minX, y: frame.minY)
    }
}

extension ImageBounds {
    /// Calculate the actual frame of an image displayed with .aspectRatio(.fit)
    /// within a container
    static func calculate(imageSize: CGSize, containerSize: CGSize) -> ImageBounds {
        // Calculate the scale to fit the image
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        var displayedSize: CGSize
        var offset: CGPoint
        
        if imageAspect > containerAspect {
            // Image is wider - fit to width
            displayedSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspect
            )
            offset = CGPoint(
                x: 0,
                y: (containerSize.height - displayedSize.height) / 2
            )
        } else {
            // Image is taller - fit to height
            displayedSize = CGSize(
                width: containerSize.height * imageAspect,
                height: containerSize.height
            )
            offset = CGPoint(
                x: (containerSize.width - displayedSize.width) / 2,
                y: 0
            )
        }
        
        let frame = CGRect(origin: offset, size: displayedSize)
        return ImageBounds(frame: frame, size: displayedSize)
    }
}


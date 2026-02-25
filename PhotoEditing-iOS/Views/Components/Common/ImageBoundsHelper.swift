import SwiftUI

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
    static func calculate(imageSize: CGSize, containerSize: CGSize) -> ImageBounds {
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height

        var displayedSize: CGSize
        var offset: CGPoint

        if imageAspect > containerAspect {
            displayedSize = CGSize(
                width: containerSize.width,
                height: containerSize.width / imageAspect
            )
            offset = CGPoint(
                x: 0,
                y: (containerSize.height - displayedSize.height) / 2
            )
        } else {
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

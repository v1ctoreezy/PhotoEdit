import SwiftUI

struct DraggableTextView: View {
    let textElement: TextElement
    let containerSize: CGSize
    let imageBounds: ImageBounds
    let onPositionChange: (CGPoint) -> Void
    
    @State private var currentPosition: CGPoint = .zero
    @State private var textSize: CGSize = .zero
    
    // Padding from edges to keep text visible
    private let edgePadding: CGFloat = 10
    
    var body: some View {
        Text(textElement.text)
            .font(textElement.getFont())
            .foregroundColor(textElement.color)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            textSize = geometry.size
                        }
                        .onChange(of: geometry.size) { newSize in
                            textSize = newSize
                        }
                }
            )
            .position(
                x: currentPosition.x,
                y: currentPosition.y
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Update position during drag with constraints
                        currentPosition = constrainPosition(value.location)
                    }
                    .onEnded { value in
                        // Constrain position and convert to normalized coordinates
                        // relative to the image bounds, not the container
                        let constrainedPosition = constrainPosition(value.location)
                        let imageFrame = imageBounds.frame
                        
                        // Convert absolute position to position relative to image
                        let relativeX = constrainedPosition.x - imageFrame.minX
                        let relativeY = constrainedPosition.y - imageFrame.minY
                        
                        // Normalize relative to image size
                        let normalizedX = relativeX / imageFrame.width
                        let normalizedY = relativeY / imageFrame.height
                        let normalizedPosition = CGPoint(
                            x: min(max(normalizedX, 0), 1),
                            y: min(max(normalizedY, 0), 1)
                        )
                        onPositionChange(normalizedPosition)
                    }
            )
            .onAppear {
                // Convert from normalized coordinates (relative to image) to actual position
                let imageFrame = imageBounds.frame
                let initialPosition = CGPoint(
                    x: imageFrame.minX + textElement.position.x * imageFrame.width,
                    y: imageFrame.minY + textElement.position.y * imageFrame.height
                )
                currentPosition = constrainPosition(initialPosition)
            }
            .onChange(of: containerSize) { _ in
                // Update position when container size changes
                let imageFrame = imageBounds.frame
                let newPosition = CGPoint(
                    x: imageFrame.minX + textElement.position.x * imageFrame.width,
                    y: imageFrame.minY + textElement.position.y * imageFrame.height
                )
                currentPosition = constrainPosition(newPosition)
            }
            .onChange(of: imageBounds.frame) { _ in
                // Update position when image bounds change
                let imageFrame = imageBounds.frame
                let newPosition = CGPoint(
                    x: imageFrame.minX + textElement.position.x * imageFrame.width,
                    y: imageFrame.minY + textElement.position.y * imageFrame.height
                )
                currentPosition = constrainPosition(newPosition)
            }
            .onChange(of: textElement.position) { newPosition in
                // Update position when text element position changes externally
                let imageFrame = imageBounds.frame
                let newActualPosition = CGPoint(
                    x: imageFrame.minX + newPosition.x * imageFrame.width,
                    y: imageFrame.minY + newPosition.y * imageFrame.height
                )
                currentPosition = constrainPosition(newActualPosition)
            }
            .onChange(of: textElement.text) { _ in
                // Re-constrain position when text changes (text size may have changed)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    currentPosition = constrainPosition(currentPosition)
                }
            }
            .onChange(of: textElement.fontSize) { _ in
                // Re-constrain position when font size changes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    currentPosition = constrainPosition(currentPosition)
                }
            }
    }
    
    // MARK: - Helper Methods
    
    private func constrainPosition(_ position: CGPoint) -> CGPoint {
        // Calculate the actual text bounds based on textSize
        let halfWidth = textSize.width / 2
        let halfHeight = textSize.height / 2
        
        // Get the image bounds within the container
        let imageFrame = imageBounds.frame
        
        // Ensure text doesn't go outside the image bounds
        let minX = imageFrame.minX + halfWidth + edgePadding
        let maxX = imageFrame.maxX - halfWidth - edgePadding
        let minY = imageFrame.minY + halfHeight + edgePadding
        let maxY = imageFrame.maxY - halfHeight - edgePadding
        
        // If text is larger than image, center it within image
        let constrainedX: CGFloat
        let constrainedY: CGFloat
        
        if maxX < minX {
            // Text is wider than image
            constrainedX = imageFrame.midX
        } else {
            constrainedX = min(max(position.x, minX), maxX)
        }
        
        if maxY < minY {
            // Text is taller than image
            constrainedY = imageFrame.midY
        } else {
            constrainedY = min(max(position.y, minY), maxY)
        }
        
        return CGPoint(x: constrainedX, y: constrainedY)
    }
}


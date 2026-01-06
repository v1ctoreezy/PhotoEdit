import SwiftUI

struct DraggableTextView: View {
    let textElement: TextElement
    let containerSize: CGSize
    let onPositionChange: (CGPoint) -> Void
    
    @State private var currentPosition: CGPoint = .zero
    
    // Padding from edges to keep text visible
    private let edgePadding: CGFloat = 20
    
    var body: some View {
        Text(textElement.text)
            .font(textElement.getFont())
            .foregroundColor(textElement.color)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
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
                        let constrainedPosition = constrainPosition(value.location)
                        let normalizedX = constrainedPosition.x / containerSize.width
                        let normalizedY = constrainedPosition.y / containerSize.height
                        let normalizedPosition = CGPoint(
                            x: min(max(normalizedX, 0), 1),
                            y: min(max(normalizedY, 0), 1)
                        )
                        onPositionChange(normalizedPosition)
                    }
            )
            .onAppear {
                // Convert from normalized coordinates to actual position
                currentPosition = CGPoint(
                    x: textElement.position.x * containerSize.width,
                    y: textElement.position.y * containerSize.height
                )
            }
            .onChange(of: containerSize) { newSize in
                // Update position when container size changes
                currentPosition = CGPoint(
                    x: textElement.position.x * newSize.width,
                    y: textElement.position.y * newSize.height
                )
            }
            .onChange(of: textElement.position) { newPosition in
                // Update position when text element position changes externally
                currentPosition = CGPoint(
                    x: newPosition.x * containerSize.width,
                    y: newPosition.y * containerSize.height
                )
            }
    }
    
    // MARK: - Helper Methods
    
    private func constrainPosition(_ position: CGPoint) -> CGPoint {
        let minX = edgePadding
        let maxX = containerSize.width - edgePadding
        let minY = edgePadding
        let maxY = containerSize.height - edgePadding
        
        return CGPoint(
            x: min(max(position.x, minX), maxX),
            y: min(max(position.y, minY), maxY)
        )
    }
}


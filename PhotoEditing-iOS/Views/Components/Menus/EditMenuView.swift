import SwiftUI
import QCropper

struct EditMenuView: View {
    
    @EnvironmentObject var shared: PhotoEditingController
    @State private var currentView: EditView = .lut
    
    // MARK: - Computed Properties
    
    private var shouldShowToolbar: Bool {
        !isFilterEditingActive && !shared.lutsCtrl.editingLut
    }
    
    private var isFilterEditingActive: Bool {
        currentView == .filter && shared.currentEditMenu != .none
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if shouldShowToolbar {
                    EditToolbar(
                        currentView: $currentView,
                        width: geometry.size.width,
                        onUndo: handleUndo,
                        onSwitchToFilter: handleSwitchToFilter
                    )
                }
                
                Spacer()
                
                contentView
                
                Spacer()
            }
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        switch currentView {
        case .filter:
            FilterMenuUI()
        case .lut:
            LutMenuUI()
        case .recipe:
            RecipeMenuUI()
        case .text:
            TextMenuView()
        }
    }
    
    // MARK: - Actions
    
    private func handleUndo() {
        shared.didReceive(action: PhotoEditingControllerAction.undo)
    }
    
    private func handleSwitchToFilter() {
        guard !shared.lutsCtrl.loadingLut else { return }
        currentView = .filter
        shared.didReceive(action: PhotoEditingControllerAction.commit)
    }
}

// MARK: - Edit Toolbar

private struct EditToolbar: View {
    @EnvironmentObject var shared: PhotoEditingController
    @Binding var currentView: EditView
    
    let width: CGFloat
    let onUndo: () -> Void
    let onSwitchToFilter: () -> Void
    
    var body: some View {
        HStack(spacing: 32) {
            NavigationLink(destination: cropperView) {
                IconButton("crop.rotate")
                    .foregroundColor(.white)
            }
            
            ToolbarButton(
                icon: "square.stack.3d.up",
                isHighlighted: currentView == .lut,
                action: { currentView = .lut }
            )
            
            ToolbarButton(
                icon: "slider.horizontal.3",
                isHighlighted: currentView == .filter,
                action: onSwitchToFilter
            )
            
            ToolbarButton(
                icon: "book.closed",
                isHighlighted: currentView == .recipe,
                action: { currentView = .recipe }
            )
            
            Button(action: { currentView = .text }) {
                Image(systemName: "textformat")
                    .font(.system(size: 24))
                    .foregroundColor(currentView == .text ? .blue : .white)
            }
            
            ToolbarButton(
                icon: "arrow.uturn.backward",
                isHighlighted: false,
                action: onUndo
            )
        }
        .frame(width: width, height: 50)
        .background(Color.myPanel)
    }
    
    private var cropperView: some View {
        CustomCropperView()
            .navigationBarTitle("")
            .navigationBarHidden(true)
    }
}

// MARK: - Toolbar Button

private struct ToolbarButton: View {
    let icon: String
    var isHighlighted: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isHighlighted ? .blue : .white)
        }
    }
}

// MARK: - Edit View Enum

public enum EditView {
    case lut
    case filter
    case recipe
    case text
}

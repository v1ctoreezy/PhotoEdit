import SwiftUI

struct FilterMenuUI: View {
    
    @EnvironmentObject var shared: PhotoEditingController
    
    private var currentEditMenu: EditMenu {
        shared.currentEditMenu
    }
    
    var body: some View {
        ZStack {
            FilterSelectionView()
            
            if shared.currentFilter.edit != .none {
                FilterControlPanel(
                    editMenu: currentEditMenu,
                    filterName: shared.currentFilter.name,
                    onCancel: handleCancel,
                    onConfirm: handleConfirm
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleCancel() {
        shared.didReceive(action: PhotoEditingControllerAction.revert)
        shared.currentFilter = FilterModel.noneFilterModel
    }
    
    private func handleConfirm() {
        shared.didReceive(action: PhotoEditingControllerAction.commit)
        shared.currentFilter = FilterModel.noneFilterModel
    }
}

// MARK: - Filter Selection View

private struct FilterSelectionView: View {
    var body: some View {
        VStack {
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    Spacer().frame(width: 0)
                    ForEach(Constants.supportFilters, id: \.name) { filter in
                        ButtonView(action: filter)
                    }
                    Spacer().frame(width: 0)
                }
            }
            
            Spacer()
            
            Text("Edit Color")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.myGrayLight)
                .padding(.bottom, 8)
        }
    }
}

// MARK: - Filter Control Panel
private struct FilterControlPanel: View {
    let editMenu: EditMenu
    let filterName: String
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            controlView(for: editMenu)
            
            Spacer()
            
            ActionButtonsBar(
                filterName: filterName,
                onCancel: onCancel,
                onConfirm: onConfirm
            )
        }
        .padding(.horizontal)
        .background(Color.myBackground)
    }
    
    // MARK: - Control View Factory
    
    @ViewBuilder
    private func controlView(for menu: EditMenu) -> some View {
        switch menu {
        case .color:
            ColorControl()
        case .contrast:
            ContrastControl()
        case .vignette:
            VignetteControl()
        case .fade:
            FadeControl()
        case .highlights:
            HighlightsControl()
        case .hls:
            HLSControl()
        case .exposure:
            ExposureControl()
        case .saturation:
            SaturationControl()
        case .shadows:
            ShadowsControl()
        case .sharpen:
            SharpenControl()
        case .temperature:
            TemperatureControl()
        case .tone:
            ToneControl()
        case .white_balance:
            WhiteBalanceControl()
        case .clarity:
//            ClarityControl()
            EmptyView()
        case .gaussianBlur:
            Text("Gaussian Blur - Coming Soon")
                .foregroundColor(.white)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Action Buttons Bar

private struct ActionButtonsBar: View {
    let filterName: String
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(filterName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.myGrayLight)
            
            Spacer()
            
            Button(action: onConfirm) {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 8)
    }
}

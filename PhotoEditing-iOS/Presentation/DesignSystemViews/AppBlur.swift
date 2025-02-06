//
//  AppBlur.swift
//  UMobile
//
//  Created by Good Shmorning on 16.12.2024.
//

import SwiftUI

struct AppBlur: View {
    let radius: CGFloat
    
    @ViewBuilder
    var body: some View {
        BackdropView().blur(radius: radius, opaque: true)
    }
}

struct BackdropView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(true)
        animator.finishAnimation(at: .start)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }

}


struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> BackgroundBlurViewHelper {
        return BackgroundBlurViewHelper()
    }

    func updateUIView(_ uiView: BackgroundBlurViewHelper, context: Context) { }
}

class BackgroundBlurViewHelper: UIVisualEffectView {
    init() {
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        if let backdropLayer = layer.sublayers?.first {
            backdropLayer.filters = []
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
}

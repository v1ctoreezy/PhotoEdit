//
//  AppLoader.swift
//  UMobile
//
//  Created by Good Shmorning on 16.12.2024.
//

import SwiftUI

struct AppLoader: View {
    
    let loaderGradient: (Color, Color)
    @Binding var isShowing: Bool
    
    let width: CGFloat
    let height: CGFloat
    let lineWidth: CGFloat
    
    let trackerRotation: Double = 2
    let animationDuration: Double = 0.75
    
    @State var circleStart: CGFloat = 0.17
    @State var circleEnd: CGFloat = 0.325
    @State var rotationDegree: Angle = Angle.degrees(0)
    
    var body: some View {
        
        
        Circle()
            .trim(from: circleStart, to: circleEnd)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .fill(LinearGradient(gradient: .init(colors: [loaderGradient.0, loaderGradient.1]),
                                 startPoint: .topLeading, endPoint: .trailing))
            .rotationEffect(self.rotationDegree)
            .frame(width: width, height: height)
            .onAppear() {
                if isShowing {
                    self.animateLoader()
                    Timer.scheduledTimer(withTimeInterval: self.trackerRotation * self.animationDuration + (self.animationDuration), repeats: true) { _ in
                        self.animateLoader()
                    }
                }
            }
            .opacity(isShowing ? 1 : 0)
    }

}

extension AppLoader {
    
    private func getRotationAngle() -> Angle {
        return .degrees(360 * self.trackerRotation) + .degrees(120)
    }
    
    private func animateLoader() {
        withAnimation(Animation.spring(response: animationDuration * 2 )) {
            self.rotationDegree = .degrees(-57.5)
        }
        
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.trackerRotation * self.animationDuration)) {
                self.rotationDegree += self.getRotationAngle()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: animationDuration * 1.25, repeats: false) { _ in
            withAnimation(Animation.easeOut(duration: (self.trackerRotation * self.animationDuration) / 2.25 )) {
                self.circleEnd = 0.925
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: trackerRotation * animationDuration, repeats: false) { _ in
            self.rotationDegree = .degrees(47.5)
            withAnimation(Animation.easeOut(duration: self.animationDuration)) {
                self.circleEnd = 0.325
            }
        }
    }
}

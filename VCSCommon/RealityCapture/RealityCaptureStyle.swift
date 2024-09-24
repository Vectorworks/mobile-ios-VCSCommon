import Foundation
import SwiftUI

public struct RealityCaptureVisualEffectRoundedCorner: ViewModifier {
    
    let padding: CGFloat
    
    public init(padding: CGFloat = 16.0) {
        self.padding = padding
    }
    
    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .font(.subheadline)
            .bold()
            .foregroundColor(.white)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .cornerRadius(15)
            .multilineTextAlignment(.center)
    }
}

public extension Image {
    func realityCaptureImageModifier(padding: CGFloat = 20.0,frameWidth: CGFloat = 22.0, frameHeight: CGFloat = 22.0, aspectRation: ContentMode = .fit, foregroundColor: Color = .white, hasDarkModeAppearance: Bool = false) -> some View {
        self.resizable()
            .aspectRatio(contentMode: aspectRation)
            .frame(width: frameWidth, height: frameHeight, alignment: .center)
            .foregroundColor(hasDarkModeAppearance ? nil : foregroundColor)
            .padding(padding)
            .contentShape(.rect)
    }
}

public struct RealityCaptureMainActionButtonCapsuleEffect: ViewModifier {
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .font(.body)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .background(.blue)
            .clipShape(Capsule())
    }
}

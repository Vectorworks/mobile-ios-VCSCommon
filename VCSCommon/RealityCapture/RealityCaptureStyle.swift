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
    func realityCaptureImageModifier(padding: CGFloat = 20.0,frameWidth: CGFloat = 22.0, frameHeight: CGFloat = 22.0, aspectRation: ContentMode = .fit, foregroundColor: Color = .white, hasDarkModeAppearance: Bool = false, font: Font? = nil) -> some View {
        self.resizable()
            .aspectRatio(contentMode: aspectRation)
            .frame(width: frameWidth, height: frameHeight, alignment: .center)
            .foregroundColor(hasDarkModeAppearance ? nil : foregroundColor)
            .font(font != nil ? font : nil)
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

public struct RealityCaptureVisualEffectRoundedCornerStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        ButtonWithEnvironmentValues(configuration: configuration)
        
    }
    
    struct ButtonWithEnvironmentValues: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            configuration.label
                .padding(16)
                .font(.subheadline)
                .bold()
                .if(isEnabled == false, transform: {
                    $0.foregroundStyle(.gray)
                })
                .if(isEnabled == true, transform: {
                    $0.foregroundColor(.white)
                })
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }
    }
}

extension ButtonStyle where Self == RealityCaptureVisualEffectRoundedCornerStyle {
    @MainActor public static var realityCaptureVisualEffectRoundedCornerStyle: RealityCaptureVisualEffectRoundedCornerStyle { RealityCaptureVisualEffectRoundedCornerStyle() }
}

public struct ActionButtonRoundedCornerStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        ButtonWithEnvironmentValues(configuration: configuration)
        
    }
    
    struct ButtonWithEnvironmentValues: View {
        let configuration: ButtonStyle.Configuration
        @Environment(\.isEnabled) private var isEnabled: Bool
        var body: some View {
            configuration.label
                .padding(16)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .if(isEnabled == false, transform: {
                    $0.background(.ultraThinMaterial)
                    
                })
                .if(isEnabled == true, transform: {
                    $0.background(.blue)
                })
                .environment(\.colorScheme, .dark)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }
    }
}

extension ButtonStyle where Self == ActionButtonRoundedCornerStyle {
    @MainActor public static var actionButtonRoundedCornerStyle: ActionButtonRoundedCornerStyle { ActionButtonRoundedCornerStyle() }
}

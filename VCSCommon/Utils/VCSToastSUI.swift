import SwiftUI

public struct VCSToastSUI: ViewModifier {
    public static let short: TimeInterval = 2
    public static let long: TimeInterval = 3.5
    
    public let message: String
    @Binding public var isShowing: Bool
    public let config: Config
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
    }
    
    private var toastView: some View {
        VStack {
            if config.position == .bottom || config.position == .center {
                Spacer()
            }
            if isShowing {
                Group {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(config.textColor)
                        .font(config.font)
                        .padding(8)
                }
                .background(config.backgroundColor)
                .cornerRadius(8)
                .onTapGesture {
                    isShowing = false
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                        isShowing = false
                    }
                }
            }
            if config.position == .top || config.position == .center {
                Spacer()
            }
        }
        .padding(20)
        .animation(config.animation, value: isShowing)
        .transition(config.transition)
    }
    
    public struct Config {
        let textColor: Color
        let font: Font
        let backgroundColor: Color
        let duration: TimeInterval
        let transition: AnyTransition
        let animation: Animation
        let position: Position
        
        init(textColor: Color = .white,
             font: Font = .system(size: 14),
             backgroundColor: Color = .black.opacity(0.588),
             duration: TimeInterval = VCSToastSUI.short,
             transition: AnyTransition = .opacity,
             animation: Animation = .linear(duration: 0.3),
             position: Position = .bottom) {
            self.textColor = textColor
            self.font = font
            self.backgroundColor = backgroundColor
            self.duration = duration
            self.transition = transition
            self.animation = animation
            self.position = position
        }
    }
    
    public enum Position {
        case top
        case bottom
        case center
    }
}

public extension View {
    func toast(message: String,
               isShowing: Binding<Bool>,
               config: VCSToastSUI.Config) -> some View {
        self.modifier(VCSToastSUI(message: message,
                                  isShowing: isShowing,
                                  config: config))
    }
    
    func toast(message: String,
               isShowing: Binding<Bool>,
               duration: TimeInterval,
               position: VCSToastSUI.Position) -> some View {
        self.modifier(VCSToastSUI(message: message,
                                  isShowing: isShowing,
                                  config: .init(duration: duration,
                                               position: position)))
    }
}

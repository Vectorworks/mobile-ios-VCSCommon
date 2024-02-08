import SwiftUI

public extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    var UIIdiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    var isPhone: Bool { UIIdiom == .phone }
    var isPad: Bool { UIIdiom == .pad }
}

public struct IsHiddenBindSUI: ViewModifier {
    @Binding var isHidden: Bool

    public func body(content: Content) -> some View {
        content
            .if(isHidden, transform: {
                $0.hidden()
            })
    }
}
public struct IsHiddenSUI: ViewModifier {
    let isHidden: Bool

    public func body(content: Content) -> some View {
        content
            .if(isHidden, transform: {
                $0.hidden()
            })
    }
}

public extension View {
    func isHidden(_ value: Binding<Bool>) -> some View {
        modifier(IsHiddenBindSUI(isHidden: value))
    }
    func isHidden(_ value: Bool) -> some View {
        modifier(IsHiddenSUI(isHidden: value))
    }
}

public extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}

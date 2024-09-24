import SwiftUI

@available(iOS 17.0, *)
public struct CaptureCancelButton: View {
    @Environment(\.dismiss) private var dismiss

    var addAction: (() -> Void)? = nil
    
    public init(addAction: (() -> Void)? = nil) {
        self.addAction = addAction
    }
    
    public var body: some View {
        Button(action: {
            if let action = addAction {
                action()
            }
            dismiss()
        }, label: {
            Text("Cancel".vcsLocalized)
                .modifier(RealityCaptureVisualEffectRoundedCorner())
        })
    }
}

@available(iOS 17.0, *)
public struct RealityCaptureButton: View {
    let title: String
    var addAction: (() -> Void)? = nil
    
    public init(title: String, addAction: (() -> Void)? = nil) {
        self.title = title
        self.addAction = addAction
    }
    
    public var body: some View {
        Button(action: {
            if let action = addAction {
                action()
            }
        }, label: {
            Text(title)
                .modifier(RealityCaptureVisualEffectRoundedCorner())
        })
    }
}


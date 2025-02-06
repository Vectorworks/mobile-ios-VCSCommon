import SwiftUI

public struct ButtonDismissSheet: View {
    let parentDismiss: DismissAction
    
    public init(_ parentDismiss: DismissAction) {
        self.parentDismiss = parentDismiss
    }
    
    public var body: some View {
        Button(action: {
            parentDismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.buttonDismissSheetFill)
                .background(Color.black.padding(.all, 4.0))
                .clipShape(Circle())
        }
    }
}

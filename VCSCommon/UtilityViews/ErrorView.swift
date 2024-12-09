import Foundation
import SwiftUI

public struct VCSErrorView: View {
    let error: String
    let onDismiss: (() -> Void)
    
    public var body: some View {
        VStack {
            Label(title: {
                Text(error)
            }, icon: {
                Image(systemName: "exclamationmark.triangle")
            })
            Button {
                onDismiss()
            } label: {
                Text("Close".vcsLocalized)
            }
        }
    }
}

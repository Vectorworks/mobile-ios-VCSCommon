import Foundation
import SwiftUI

public struct VCSProgressView: View {
    public let loadingTask: (() -> Void)
    
    public var body: some View {
        ProgressView()
            .controlSize(.extraLarge)
            .task {
                loadingTask()
            }
    }
}

public struct VCSWideProgressView: View {
    public let loadingTask: (() -> Void)
    
    public var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .controlSize(.extraLarge)
                .task {
                    loadingTask()
                }
            Spacer()
        }
    }
}

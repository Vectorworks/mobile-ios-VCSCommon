import SwiftUI

public struct ExecuteCodeEmptyView : View {
    public init( _ codeToExec: () -> () ) {
        codeToExec()
    }
    
    public var body: some View {
        return EmptyView()
    }
}
